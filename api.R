# api.R
# REST API for Kenya National Debt Counter

library(plumber)
library(jsonlite)
library(dplyr)

# Load environment variables safely
anthropic_api_key <- Sys.getenv("ANTHROPIC_API_KEY")
supabase_url <- Sys.getenv("SUPABASE_URL")
supabase_api <- Sys.getenv("SUPABASE_API_KEY")

# Load data and calculation functions
source("data_loader.R")

#* @apiTitle Kenya National Debt Counter API
#* @apiDescription Backend API for real-time debt counter, fiscal data, and AI assistant

# ============================================================
# CORS MIDDLEWARE
# ============================================================

#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

# ============================================================
# HEALTH CHECK
# ============================================================

#* @get /health
function() {
  list(
    status = "healthy",
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    version = "1.0.0"
  )
}

# ============================================================
# DEBT ENDPOINTS
# ============================================================

#* @get /api/debt/current
function() {
  list(
    success = TRUE,
    data = list(
      total = calculate_total_debt(),
      domestic = calculate_domestic_debt(),
      external = calculate_external_debt(),
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      date = format(Sys.Date(), "%d %b %Y")
    )
  )
}

#* @get /api/debt/growth
function(unit = "sec") {
  growth <- calculate_growth(unit)
  
  list(
    success = TRUE,
    data = list(
      unit = unit,
      total = growth$total,
      domestic = growth$domestic,
      external = growth$external
    )
  )
}

#* @get /api/debt/historical
function() {
  data <- get_debt_historical()
  
  if (is.null(data)) {
    return(list(success = FALSE, error = "No data available"))
  }
  
  list(success = TRUE, data = data)
}

# ============================================================
# EXPENDITURE
# ============================================================

#* @get /api/expenditure/current
function() {
  list(
    success = TRUE,
    data = list(
      expenditure = calculate_expenditure(),
      revenue = calculate_revenue(),
      deficit = calculate_deficit(),
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
  )
}

# ============================================================
# INDICATORS
# ============================================================

#* @get /api/indicators/current
function() {
  list(
    success = TRUE,
    data = list(
      gdp = calculate_gdp(),
      population = calculate_population(),
      forex = forex_today,
      domestic_interest_rate = int_rate_dom,
      external_interest_rate = int_rate_ext
    )
  )
}

# ============================================================
# AI ASSISTANT
# ============================================================

#* @post /api/ai/chat
function(req, res) {
  
  body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) NULL)
  
  if (is.null(body) || is.null(body$question) || body$question == "") {
    return(list(success = FALSE, error = "No question provided"))
  }
  
  if (anthropic_api_key == "") {
    return(list(success = FALSE, error = "API key not configured"))
  }
  
  tryCatch({
    
    result <- claude_chat_with_context(body$question)
    
    list(
      success = TRUE,
      response = as.character(result$response),
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    
  }, error = function(e) {
    list(success = FALSE, error = as.character(e$message))
  })
}

# ============================================================
# SIMULATION
# ============================================================

#* @post /api/simulate
function(req) {
  
  body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) NULL)
  
  if (is.null(body)) {
    return(list(success = FALSE, error = "Invalid input"))
  }
  
  results <- run_simulation(
    body$end_year,
    body$rev_growth,
    body$exp_growth,
    body$int_rate,
    body$primary_bal
  )
  
  list(success = TRUE, data = results)
}

# ============================================================
# LOGGING
# ============================================================

#* @post /api/log/visit
function(req) {
  
  visitor_data <- list(
    session_id = paste0(sample(letters, 10, TRUE), collapse = ""),
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  )
  
  list(success = TRUE, message = "Logged")
}

# ============================================================
# START SERVER (THIS IS THE KEY ADDITION FOR RENDER)
# ============================================================

cat("🚀 API starting on Render...\n")

pr <- plumb("api.R")

pr$run(
  host = "0.0.0.0",
  port = as.numeric(Sys.getenv("PORT"))
)