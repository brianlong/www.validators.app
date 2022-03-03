<template>
  <div>
    <div class="page-header">
      <h1>Ping Thing</h1>
      <p>
        We use this Ping Thing to show recent transaction confirmation times on the Solana blockchain. The <a href='https://www.blocklogic.net' target='_blank'>Block Logic Validator</a> is sending simple transfer transactions every 15 seconds and the confirmation times appear below. You can use these pings as a gauge of cluster performance.
      </p>
      <p>
        This is a very simple first iteration with many improvements on the way. Upcoming features include: REST API to download data, interactive chart with custom timeframes, statistics for a given period of time, and more.
      </p>
      <p>
        App developers, you can also upload your own TX confirmation times using our <a href="/api-documentation">REST API</a>. Any Solana application or transaction type is allowed. Use this tool to show recent confirmation times to your users.
      </p>
      <p>
        I would like to get feedback from Solana developers on how we can make this tool more useful for your applications. Please contact me at @ValidatorsApp on Twitter. -- @brianlong
      </p>
      <p>
        NOTES: We use a 60-second timeout threshold for the pings. On the chart and table below, a value of 60,000 milliseconds means that the operation failed or took longer than 60 seconds to complete.
      </p>
      <div class="text-danger">This feature is a work-in-progress. Please contact @ValidatorsApp on Twitter with feedback.</div>
    </div>
    <!--
    <div class="card mb-4">
      <div class="card-content">
        <h3 class="card-heading mb-4"><%= params[:network].capitalize %> TX Confirmation Time</h3>
        <%= render 'scatter_chart',
                  chart_name: "scatter_chart_response_times",
                  vector: @ping_things_array_for_chart,
                  line_color: SPARK_LINE_2,
                  fill_color: SPARK_LINE_2_TRANSPARENT,
                  y_axis_desc: 'Response Time (ms)',
                  x_axis_desc: "Last #{@ping_things_count} Observations"
        %>
      </div>
    </div>
    <div class="">

    </div>
    <div class="card">
      <div class="table-responsive-lg">
        <table class='table mb-0'>
          <thead>
          <tr>
            <th class="align-middle column-md-sm">Success / Time</th>
            <th class="align-middle column-lg">
              Reported&nbsp;At<br />
              <span class="small text-muted">Signature</span>
            </th>
            <th class="align-middle column-lg">
              Application<br />
              <span class="small text-muted">Type (Commitment Level)</span>
            </th>
            <th class="align-middle column-xs">Posted&nbsp;By</th>
          </tr>
          </thead>

          <tbody>
          <% @ping_things.each.with_index do |pt, index| %>
            <tr>
              <td class="align-middle">
                <%= success_icon(pt.success).html_safe %>
                <strong class="text-success h6"><%= number_with_delimiter(pt.response_time) %></strong>&nbsp;ms
              </td>
              <td class="align-middle small">
                <%= pt.reported_at %><br />
                <span class="word-break"><%= link_to shorten_key(pt.signature), link_from_signature(pt.signature), target: "_blank", class: "small"%></span>
              </td>
              <td class="align-middle small">
                <% if pt.application %>
                  <%= pt.application %><br />
                <% end %>
                <span class="text-muted">
                  <%= transaction_type_icon(pt.transaction_type).html_safe %><%= pt.transaction_type %>
                  <% if pt.commitment_level %>(<%= pt.commitment_level %>)<% end %>
                </span>
              </td>
              <td class="align-middle text-muted"><%= pt.user.username %></td>
            </tr>
          <% end %>
          </tbody>
        </table>
      </div>
    </div>
    -->
  </div>
</template>
