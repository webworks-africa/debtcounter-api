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
    endpoints = c("/health", "/api/debt/current")
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
  list(
    success = TRUE,
    data = list(
      total = calculate_total_debt(),
      domestic = calculate_domestic_debt(),
      external = calculate_external_debt(),
      timestamp = Sys.time()
    )
  )
}

#* @get /api/debt/growth
function(unit = "sec") {
  growth <- calculate_growth(unit)

  list(
    success = TRUE,
    data = growth
  )
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
      deficit = calculate_deficit()
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
      population = calculate_population()
    )
  )
}