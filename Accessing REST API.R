#Source: https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08

#Register a new application with Github and use OAuth credentials 

install.packages("jsonlite")
library(jsonlite)
install.packages("httpuv")
library(httpuv)
install.packages("httr")
library(httr)
install.packages("plotly")
library(plotly)
install.packages("ggplot2")
library(ggplot2)
install.packages("devtools")
library(devtools)

# Choose application
oauth_endpoints("github")
myapp <- oauth_app(appname = "Jason_Yang_CSU33012",
                   key = "e9093eb1c78f99cdf681",
                   secret = "aae80d1e1ee90cd626ce01297667ef508ab68a17")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/yangja1/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "yangja1/LCA", "created_at"] 

#When it asks you to 'enter an item from the menu, or 0 to exit'
#The options are 1 - Yes or 2 - No to using a local file to cache oAuth credentials between R sessions
#Please press 1

########################################################################################################

### Collecting & Displaying My Data
# Get my data
myData = fromJSON("https://api.github.com/users/yangja1")

# Display the number of followers
myData$followers

# Gives user names of all my followers
followers = fromJSON("https://api.github.com/users/yangja1/followers")
followers$login

# Display the number of users I am following
myData$following

# Gives user names of all the users I am following
following = fromJSON("https://api.github.com/users/yangja1/following")
following$login

# Display the number of repositories I have
myData$public_repos

# Gives the name and creation date for my repositories
repositories = fromJSON("https://api.github.com/users/yangja1/repos")
repositories$name
repositories$created_at

#For this assignment I have used Tom Preston-Werner's Github Account - mojombo
#He has over 22.2k followers and is the co-founder and ex-CEO of Github

#Like last time, prepare the data before running it:
allData = GET("https://api.github.com/users/mojombo", gtoken)
dataCont = content(allData)
followers = GET("https://api.github.com/users/mojombo/followers?per_page=100", gtoken)
followCont = content(followers)
repository = GET("https://api.github.com/users/mojombo/repos", gtoken)
repoCont = content(repository)

dataFrame = jsonlite::fromJSON(jsonlite::toJSON(dataCont))
followerFrame = jsonlite::fromJSON(jsonlite::toJSON(followCont))
repoFrame = jsonlite::fromJSON(jsonlite::toJSON(repoCont))

dataFrame$followers         #Num followers
dataFrame$public_repos      #Num public repositories
dataFrame$login             #login name

length(followerFrame$login)
repoFrame$name              #Repo names
repoFrame$created_at        #Date repo created

# List of usernames
followerFrame$login        
user_ids = c(followerFrame$login)

# Create empty set
users = c()
usersDB = data.frame(username = integer(), following = integer(), followers = integer(), repos = integer(), dateCreated = integer())

#Add users to list
for(i in 1:length(user_ids))
{
  followURL = paste("https://api.github.com/users/", user_ids[i], "/following", sep = "")
  followReq = GET(followURL, gtoken)
  followCont = content(followReq)
  
  if(length(followCont) == 0)
  {
    next
  }
  
  followDFrame = jsonlite::fromJSON(jsonlite::toJSON(followCont))
  followLog = followDFrame$login
  
  #Loop through users
  for (j in 1:length(followLog))
  {
    if (is.element(followLog[j], users) == FALSE)
    {
      users[length(users) + 1] = followLog[j] #Adds user to list
      
      followURL2 = paste("https://api.github.com/users/", followLog[j], sep = "")
      following2 = GET(followURL2, gtoken)
      followCont2 = content(following2)
      followDFrame2 = jsonlite::fromJSON(jsonlite::toJSON(followCont2))
      
      
      followingNumber = followDFrame2$following #following
      followersNumber = followDFrame2$followers #followers
      reposNumber = followDFrame2$public_repos  #Repo num
      yearCreated = substr(followDFrame2$created_at, start = 1, stop = 4) #year joined
      
      usersDB[nrow(usersDB) + 1, ] = c(followLog[j], followingNumber, followersNumber, reposNumber, yearCreated)
    }
    next
  }
  if(length(users) > 100) #stop after 100 entries
  {
    break
  }
  next
}

#Plotly is an add on to R that creates interactive online graphs
#The following links this code to my Plotly Chart Studio account
Sys.setenv("plotly_username"="yangja1")
Sys.setenv("plotly_api_key"="iCbUmF6HfmkwiSzr8yxv")

#Plot 1 - Repositories vs Followers by Year
plot1 = plot_ly(data = usersDB, x = ~repos, y = ~followers, text = ~paste("Followers: ", followers, "<br>Repositories: ", repos, "<br>Date Created:", dateCreated), color = ~dateCreated)
plot1
# Sends graph to plotly
api_create(plot1, filename = "Repositories vs Followers")
