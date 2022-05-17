<template>
  <div class="page-header">
    <h1>Ping Thing</h1>
    <p>
      We use this Ping Thing to show recent transaction confirmation times on the Solana blockchain.
      The <a href='https://www.blocklogic.net' target='_blank'>Block Logic Validator</a> plus several other
      validators are sending simple transfer transactions every 15 seconds and the confirmation times appear
      below. You can use these pings as a gauge of cluster performance.
    </p>
    <p>
      All data is available for download from our <a href="/api-documentation">REST API</a>. App developers, you can
      also upload your own TX confirmation times. Any Solana application or transaction type is allowed. Use this
      tool to show recent confirmation times to your users.
    </p>
    <p>
      I would like to get feedback from Solana developers on how we can make this tool more useful for your
      applications. Please contact me at @ValidatorsApp on Twitter. -- @brianlong
    </p>
    <p>
      NOTES: We use a 60-second timeout threshold for the pings. On the chart and table below, a value of 60,000
      milliseconds means that the operation failed or took longer than 60 seconds to complete.
    </p>
  </div>
</template>
