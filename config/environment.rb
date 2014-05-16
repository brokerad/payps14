# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Slytrade::Application.initialize!

# Require FasterCSV to generate CSV files
require "fastercsv"
