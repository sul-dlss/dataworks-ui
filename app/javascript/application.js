// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from 'blacklight-frontend'

import BlacklightRangeLimit from "blacklight-range-limit";
import { customizeRangeLimitChart } from "range_limit_chart";
customizeRangeLimitChart(BlacklightRangeLimit);
BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });
