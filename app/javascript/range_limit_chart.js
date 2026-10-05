import { Chart } from "chart.js"

// Local customization of the blacklight_range_limit distribution chart.
//
// Note: the range limit gem plots density (count / bucket width) and hides the y-axis
// because that number isn't meaningful. We plot the raw document count as the
// bar height so the visible y-axis numbers represent document counts.

const BAR_COLOR_FALLBACK = "#6FC3FF"
const SEPARATOR_COLOR = "#fff"
const TICK_COLOR = "#888"
const TICK_LENGTH = 6
const DEFAULT_ASPECT_RATIO = 2
const CHART_PADDING = { top: 20, right: 12, left: 10, bottom: 0 }

// Thousands separators for the y-axis counts ("10,000")
const Y_TICK_FORMAT = new Intl.NumberFormat("en-US")

// Shared axis grid: no gridlines or axis line, just tick dashes.
const AXIS_TICK_GRID = {
  drawOnChartArea: false,
  drawTicks: true,
  tickLength: TICK_LENGTH,
  tickColor: TICK_COLOR
}

// Two stepped-line points per bucket (flat top), using count as the height.
function stepPoints(buckets) {
  return buckets.flatMap((b) => [
    { x: b.from, y: b.count },
    { x: b.to + 1, y: b.count }
  ])
}

// A white separator at each bucket boundary, sized to the taller of the two
// adjacent bars so the line only covers bar area, not the empty background.
function boundarySeparators(buckets) {
  const separators = buckets.map((b, i) => {
    const prev = buckets[i - 1]
    return { x: b.from, h: prev ? Math.max(prev.count, b.count) : b.count }
  })
  const last = buckets[buckets.length - 1]
  separators.push({ x: last.to + 1, h: last.count })
  return separators
}

function separatorsPlugin(separators) {
  return {
    id: "blrlSeparators",
    afterDatasetsDraw(chart) {
      const { ctx, chartArea, scales } = chart
      ctx.save()
      ctx.strokeStyle = SEPARATOR_COLOR
      ctx.lineWidth = 1
      separators.forEach(({ x, h }) => {
        if (h <= 0) return
        const px = scales.x.getPixelForValue(x)
        ctx.beginPath()
        ctx.moveTo(px, chartArea.bottom)
        ctx.lineTo(px, scales.y.getPixelForValue(h))
        ctx.stroke()
      })
      ctx.restore()
    }
  }
}

export function customizeRangeLimitChart(BlacklightRangeLimit) {
  // Before Turbo caches the page for back/forward, destroy the live Chart.js
  // instances. Turbo caches a *clone* of the canvas, so the original node (and
  // its Chart instance) would otherwise linger in Chart.js's registry and never
  // be collected. The canvas itself is left in place; setupDomForChart replaces
  // it with a freshly drawn one when the page is restored.
  document.addEventListener("turbo:before-cache", () => {
    document.querySelectorAll("canvas.blacklight-range-limit-chart").forEach((canvas) => {
      Chart.getChart(canvas)?.destroy()
    })
  })

  // Idempotent chart setup. Blacklight.onLoad re-runs the range limit init on
  // every turbo:load, turbo:frame-load (e.g. typing in the sidebar facet search
  // box), and back/forward restore. The gem's setupDomForChart unconditionally
  // prepends a new <canvas>, so repeated runs stack up duplicate graphs; and a
  // Turbo-restored canvas comes back blank (its 2D bitmap isn't serialized). By
  // clearing any existing canvas (and its Chart.js instance) before creating a
  // fresh one, every run yields exactly one freshly drawn chart.
  BlacklightRangeLimit.prototype.setupDomForChart = function () {
    const wrapper = this.container.querySelector("*[data-chart-wrapper=true]")

    wrapper.querySelectorAll("canvas.blacklight-range-limit-chart").forEach((canvas) => {
      Chart.getChart(canvas)?.destroy()
      canvas.remove()
    })

    const canvas = this.container.ownerDocument.createElement("canvas")
    canvas.setAttribute("aria-hidden", "true") // the textual facet list is the accessible alternative
    canvas.classList.add("blacklight-range-limit-chart")
    canvas.style.display = "inline-block"
    wrapper.style.display = "block"
    wrapper.prepend(canvas)

    this.chartCanvasElement = canvas
    return canvas
  }

  BlacklightRangeLimit.prototype.drawChart = function (chartCanvasElement) {
    const buckets = this.rangeBuckets
    if (!buckets || buckets.length === 0) return

    const points = stepPoints(buckets)
    const minX = points[0].x
    const maxX = points[points.length - 1].x
    const xTicks = this.xTicks

    const wrapper = chartCanvasElement.closest("*[data-chart-wrapper=true]")
    const aspectRatio =
      parseFloat(window.getComputedStyle(wrapper)?.getPropertyValue("aspect-ratio")) ||
      DEFAULT_ASPECT_RATIO

    const barColor =
      this.container.getAttribute("data-chart-segment-bg-color") || BAR_COLOR_FALLBACK

    new Chart(chartCanvasElement.getContext("2d"), {
      type: "line",
      plugins: [separatorsPlugin(boundarySeparators(buckets))],
      options: {
        animation: false,
        aspectRatio: aspectRatio,
        resizeDelay: 15,
        // Inset the chart from the fog panel edges; the bottom is left flush.
        layout: { padding: { ...CHART_PADDING } },
        plugins: {
          legend: false,
          tooltip: { enabled: false }
        },
        elements: { point: { radius: 0 } },
        scales: {
          x: {
            min: minX,
            max: maxX,
            type: "linear",
            grid: { ...AXIS_TICK_GRID },
            border: { display: false },
            afterBuildTicks: (axis) => {
              axis.ticks = xTicks.map((v) => ({ value: v }))
            },
            ticks: {
              autoSkip: true,
              maxRotation: 0,
              maxTicksLimit: 6,
              // Raw years, no locale grouping (avoids "2,020").
              callback: (val) => val
            }
          },
          y: {
            beginAtZero: true,
            grid: { ...AXIS_TICK_GRID },
            border: { display: false },
            ticks: {
              display: true,
              precision: 0,
              maxTicksLimit: 8,
              // A number on every other tick. Exception: with only two ticks,
              // label both so the top tick isn't left blank.
              callback: (value, index, ticks) =>
                ticks.length === 2 || index % 2 === 0 ? Y_TICK_FORMAT.format(value) : ""
            }
          }
        }
      },
      data: {
        datasets: [
          {
            data: points,
            stepped: true,
            fill: true,
            borderWidth: 0,
            backgroundColor: barColor
          }
        ]
      }
    })
  }
}
