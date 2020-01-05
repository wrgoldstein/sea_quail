import _ from "lodash"
import { color } from "d3-color"

export const raw_data = {
    "rows": [
        [
            "South",
            1620
        ],
        [
            "West",
            3203
        ],
        [
            "East",
            2848
        ],
        [
            "Central",
            2323
        ]
    ],
    "result_types": [
        "string",
        "number"
    ],
    "number_columns": [
        "orders.count"
    ],
    "non_number_columns": [
        "orders.region"
    ],
    "columns": [
        "orders.region",
        "orders.count"
    ]
}

export function chartData(data){
  if (data.rows.length <= 1) {
      return
  } else if (data.number_columns.length < 1) {
      return
  } else if (data.non_number_columns.length > 2){
      return
  }
  return data
}

export class ChartConfig {
  constructor(data) {
    this.data = data;
    this.colors = [
      '#e6194b',
      '#3cb44b',
      '#ffe119',
      '#4363d8',
      '#f58231',
      '#911eb4',
      '#46f0f0',
      '#f032e6',
      '#bcf60c',
      '#fabebe',
      '#008080',
      '#e6beff',
      '#9a6324',
      '#fffac8',
      '#800000',
      '#aaffc3',
      '#808000',
      '#ffd8b1',
      '#000075',
      '#808080',
      '#ffffff',
      '#000000'].map(color)
  }

  get availableChartTypes(){
    return [ 'bar' , 'line' ]
  }

  config(type){
    return {
      type,
      data: {
        labels: this.makeLabels(),
        datasets: this.makeDatasets(type),
      },
      options: this.makeOptions(type)
    }
  }

  makeLabels(){
    const nnc = this.data.non_number_columns
    const c = this.data.columns

    // first non number column will be our label for now
    const j = c.indexOf(nnc[0])

    return this.data.rows.map(row => row[j])
  }

  // Method
  makeDatasets(type){
    console.log(this.data.number_columns)
    return this.data.number_columns.map((label, i) => {
        let j = this.data.columns.indexOf(label)
        let values = this.data.rows.map(row => row[j])
        const backgroundColor = this.colors[i]
        backgroundColor.opacity = .2
        const borderColor = this.colors[i].darker().toString()
        
        return {
            data: values,
            labels: [label],
            backgroundColor: backgroundColor.toString(),
            borderColor,
            borderWidth: 1
          }
    })
}

  makeOptions(type){
    let base = this.baseOptions()
    if (this.data.result_types.indexOf('date') > 0) {
      return _.merge(base, this.timeSeriesOptions())
    }
    return base
  }

  baseOptions(){
    return {
        maintainAspectRatio: false,
          tooltips: {
            callbacks: {
              label: function(tooltipItem, data) {
                let label = data.datasets[tooltipItem.datasetIndex].labels[tooltipItem.datasetIndex];
                let value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index]
                if (typeof(value) == "number") {
                  value = Number(value.toFixed(2))
                }
                if (label) return label + ': ' + value
                return value
              }
            }
          },
        legend: {
          display: false
        },
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero:true
            }
          }]
        }
      }
  }

  timeSeriesOptions(){
    return {
        scales: {
            xAxes: [{
                type: 'time',
                distribution: 'linear'
                }]
            }
        }
    }
}
