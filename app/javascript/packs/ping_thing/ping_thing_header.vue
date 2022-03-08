<template>
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
</template>