###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

window.analyticsData = {
  applicationId: ->
    $('.analytics').attr('data-application-id')

  dwellTime: ->
    query = window.location.origin + "/events/dwell_times.json?application_id=" + this.applicationId() + '&limit=14'
    $.getJSON( query ).done( (data) ->
      dates = []
      values = []
      months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ]
      $.each(data.events, (k, [date, value]) ->
        m = Date.parse(date)
        d = new Date(m)
        dates.push(d.getDate() + ' ' + months[d.getMonth()])
        values.push(value)
      )
      $("#dwell-time-chart").highcharts
        chart:
          type: "areaspline"
          animation: Highcharts.svg
          events:
            load: ->
              # set up the updating of the chart each second
              series = @series[0]
              setInterval((->
                dwell_update = window.location.origin + '/events/dwell_times.json?application_id=' + analyticsData.applicationId() + '&limit=1'
                $.getJSON( dwell_update ).done( (data) ->
                  update = 0
                  $.each(data.events, (k, v) -> update = v[1])
                  series.data[series.data.length - 1].update(update)
                )
              ), 30000)

        title:
          text: null

        legend:
          enabled: false

        xAxis:
          categories: dates

        yAxis:
          allowDecimals: false
          min: 0
          title: null

        'colors': ["#62bae8"]
        'tooltip':
          'shared': true
          'formatter': ->
            s = Math.floor(this.y / 1000)
            h = Math.floor(s / 3600)
            m = Math.floor((s % 3600) / 60)

            "<b>Dwell Time: </b>#{ h }h #{ m }min"

        credits:
          enabled: false

        plotOptions:
          areaspline:
            fillOpacity: 0.5

        series: [
          name: "Dwell Time"
          data: values
        ]
    )

  actions: ->
    query = window.location.origin + '/events/action_counts.json?application_id=' + this.applicationId() + '&limit=7'

    $.getJSON( query ).done( (data) ->

      dates = []
      values = []

      $.each(data.events, (index, v) ->
        dates.push(v[0])
        values.push(v[1])
      )

      $("#actions-chart").highcharts
        chart:
          animation: Highcharts.svg
          events:
            load: ->
              # set up the updating of the chart each second
              series = @series[0]
              setInterval (->
                actions_update = window.location.origin + '/events/action_counts.json?application_id=' + analyticsData.applicationId() + '&limit=1'
                $.getJSON( actions_update ).done( (data) ->
                  update = 0
                  return unless data and data.events?
                  $.each(data.events, (k, v) -> update = v[1])
                  series.data[series.data.length - 1].update(update)
                )
              ), 30000

        title:
          text: null

        subtitle:
          text: null

        xAxis:
          categories: dates
        yAxis:
          allowDecimals: false
          min: 0
          title:
            text: null

          plotLines: [
            value: 0
            width: 1
            color: "#62bae8"
          ]

        colors: ["#62bae8"]
        tooltip:
          valueSuffix: null

        legend:
          enabled: false

        series: [
          name: "Actions"
          data: values
        ]
        credits:
          enabled: false
      )
  activeUsers: ->
    query = window.location.origin + '/events/unique_users.json?application_id=' + this.applicationId() + '&limit=7'
    $.getJSON( query ).done( (data) ->
      dates = []
      values = []

      $.each(data.events, (index, v) ->
        dates.push(v[0])
        values.push(v[1])
      )


      $("#active-users-chart").highcharts
        chart:
          type: "column"
          events:
            load: ->
              # set up the updating of the chart each second
              series = @series[0]
              setInterval (->
                actions_update = window.location.origin + '/events/unique_users.json?application_id=' + analyticsData.applicationId() + '&limit=1'
                $.getJSON( actions_update ).done( (data) ->
                  update = 0
                  $.each(data.events, (k, v) -> update = v[1])
                  series.data[series.data.length - 1].update(update)
                )
              ), 30000

        title:
          text: null

        subtitle:
          text: null

        legend:
          enabled: false

        xAxis:
          categories: dates
        yAxis:
          allowDecimals: false
          min: 0
          title: null

        colors: ["#62bae8"]
        tooltip:
          shared: true
          useHTML: true

        plotOptions:
          column:
            pointPadding: 0.2
            borderWidth: 0

        series: [
          name: "Active Users"
          data: values
        ]
        credits:
          enabled: false
      )
}

$ ->
  if $('#dwell-time-chart').length > 0
    analyticsData.dwellTime()

  if $('#actions-chart').length > 0
    analyticsData.actions()

  if $('#active-users-chart').length > 0
    analyticsData.activeUsers()




