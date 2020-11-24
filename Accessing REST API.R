#https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08
#Register a new application with Github and use OAuth credentials 

#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)

# Choose application
oauth_endpoints("github")
myapp <- oauth_app(appname = "Jason_Yang_CSU33012",
                   key = "e9093eb1c78f99cdf681",
                   secret = "aae80d1e1ee90cd626ce01297667ef508ab68a17")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/jtleek/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"] 


