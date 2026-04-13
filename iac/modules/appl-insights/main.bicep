
param logAnalyticsName string = 'log-analytics-fnol'
param applInsightsName string = 'appl-insights-fnol'
param location string = 'germanywestcentral'


// 1. The "Storage Bucket" for logs
resource logAnalyticsFnol 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018' // charged based on how much data you send to the "hard drive."
                        // there is a free tier for the first 5GB of data ingested per month.
                        // After the Free Tier: You pay around €2 per GB
    }
    retentionInDays: 30 // Azure Log Analytics provides the first 30 days of retention for free with the PerGB2018 SKU.
  }
}

// 2. The "Interface" for viewing logs
resource applInsightsFnol 'Microsoft.Insights/components@2020-02-02' = {
  name: applInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsFnol.id // This link is mandatory
  }
}

output logAnalyticsName string = logAnalyticsFnol.name
output logAnalyticsId string = logAnalyticsFnol.id
//
output applInsightsName string = applInsightsFnol.name
output applInsightsId string = applInsightsFnol.id

