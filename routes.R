library(plumber)
library(jsonlite)
library(dplyr)

# Load environment variables
anthropic_api_key <- Sys.getenv("ANTHROPIC_API_KEY")
supabase_url <- Sys.getenv("SUPABASE_URL")
supabase_api <- Sys.getenv("SUPABASE_API_KEY")

# Load logic
source("data_loader.R")

# ============================================================
# CORS
# ============================================================

#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type")

  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

# ============================================================
# ROOT
# ============================================================

#* @get /
function() {
  list(
    message = "DebtCounter API is running",
    endpoints = c(
      "/health",
      "/api/debt/current",
      "/api/debt/growth",
      "/api/debt/historical",
      "/api/debt/ratio",
      "/api/expenditure/current",
      "/api/expenditure/growth",
      "/api/expenditure/historical",
      "/api/indicators/current",
      "/api/indicators/growth",
      "/api/indicators/gdp/historical",
      "/api/indicators/population/historical",
      "/api/indicators/forex/historical",
      "/api/ai/chat",
      "/api/ai/suggestions",
      "/api/simulate",
      "/api/log/visit",
      "/api/dashboard/all"
    )
  )
}

# ============================================================
# HEALTH
# ============================================================

#* @get /health
function() {
  list(
    status = "healthy",
    time = Sys.time()
  )
}

# ============================================================
# DEBT
# ============================================================

#* @get /api/debt/current
function() {
  current_time <- Sys.time()
  list(
    success = TRUE,
    data = list(
      total = calculate_total_debt(),
      domestic = calculate_domestic_debt(),
      external = calculate_external_debt(),
      timestamp = current_time,
      date = format(current_time, "%d %B %Y")
    )
  )
}

# ============================================================
# EXPENDITURE
# ============================================================

#* @get /api/expenditure/current
function() {
  current_time <- Sys.time()
  list(
    success = TRUE,
    data = list(
      expenditure = calculate_expenditure(),
      revenue = calculate_revenue(),
      deficit = calculate_deficit(),
      timestamp = current_time,
      date = format(current_time, "%d %B %Y")
    )
  )
}

# ============================================================
# INDICATORS
# ============================================================

#* @get /api/indicators/current
function() {
  current_time <- Sys.time()
  list(
    success = TRUE,
    data = list(
      forex = calculate_exchange_rate(),
      domestic_interest_rate = calculate_domestic_rate(),
      external_interest_rate = calculate_external_rate(),
      gdp = calculate_gdp(),
      population = calculate_population(),
      timestamp = current_time,
      date = format(current_time, "%d %B %Y")
    )
  )
}

#* @get /api/indicators/growth
function(unit = "sec") {
  list(success = TRUE, data = calculate_indicators_growth(unit))
}

#* @get /api/indicators/gdp/historical
function() {
  list(success = TRUE, data = get_historical_gdp())
}

#* @get /api/indicators/population/historical
function() {
  list(success = TRUE, data = get_historical_population())
}

#* @get /api/indicators/forex/historical
function() {
  list(success = TRUE, data = get_historical_forex())
}

# ============================================================
# AI ENDPOINTS
# ============================================================

#* @post /api/ai/chat
function(req) {
  body <- jsonlite::fromJSON(req$postBody)

  question <- body$question

  # Simple mock (replace with Anthropic later)
  response <- paste("AI response to:", question)

  list(
    success = TRUE,
    response = response
  )
}

#* @get /api/ai/suggestions
function() {
  list(
    success = TRUE,
    suggestions = c(
      "What is Kenya's current debt?",
      "How has external debt changed?",
      "What are the fiscal risks?",
      "Explain debt-to-GDP ratio"
    )
  )
}

# ============================================================
# SIMULATION
# ============================================================

#* @post /api/simulate
function(req) {
  list(
    success = TRUE,
    message = "Simulation endpoint working (implement logic)"
  )
}

# ============================================================
# ANALYTICS
# ============================================================

#* @post /api/log/visit
function() {
  list(success = TRUE)
}

# ============================================================
# DASHBOARD
# ============================================================

#* @get /api/dashboard/all
function() {
  list(
    success = TRUE,
    data = list(
      debt = calculate_total_debt(),
      expenditure = calculate_expenditure(),
      gdp = calculate_gdp()
    )
  )
}