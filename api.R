library(plumber)

cat("🚀 Starting DebtCounter API on Render...\n")

# Load routes
pr <- plumber::plumb("routes.R")

# Run API
pr$run(
  host = "0.0.0.0",
  port = as.numeric(Sys.getenv("PORT"))
)