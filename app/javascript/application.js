// Entry point for the build script in your package.json
// This replaces app/javascript/packs/application.js

console.log("Application.js loaded successfully!")

// Import Rails UJS and start it
import Rails from "@rails/ujs"
if (!window.Rails) {
  Rails.start()
  console.log("Rails UJS started")
} else {
  console.log("Rails UJS already loaded, skipping")
}

// Import Turbolinks and start it  
import Turbolinks from "turbolinks"
if (!window.Turbolinks) {
  Turbolinks.start()
  console.log("Turbolinks started")
} else {
  console.log("Turbolinks already loaded, skipping")
}

// Import Active Storage and start it
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

console.log("Rails, Turbolinks, and ActiveStorage started")

// Import channels (if they exist)
// import "./channels"

// Import moment
// import moment from "moment"

// Import src files (commenting out for now)
// import './src/sol_prices_charts'
// import './src/watch_buttons' 
// import './src/chart_links'
// import './src/score_modal_trigger'
