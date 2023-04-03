import requests
import json
from datetime import datetime

# Azure DevOps organization URL
url = "https://dev.azure.com/{organization}"

# Personal Access Token (PAT) with the necessary permissions
pat = "{personal_access_token}"

# Azure DevOps project ID
project_id = "{project_id}"

# Azure DevOps repository ID
repository_id = "{repository_id}"

# REST API endpoint for pull requests
endpoint = url + "/{project_id}/{repository_id}/_apis/git/pullrequests?searchCriteria.status=active&$expand=commits"

# Headers for the REST API request
headers = {
    "Authorization": "Basic " + pat,
    "Content-Type": "application/json"
}

# Make the REST API request
response = requests.get(endpoint, headers=headers)

# Parse the JSON response
data = json.loads(response.text)

# Print the list of active pull requests with additional information
print("Active Pull Requests:\n")
for pr in data["value"]:
    print("Title:", pr["title"])
    print("Pull Request ID:", pr["pullRequestId"])
    print("Author:", pr["createdBy"]["displayName"])
    print("Creation Date:", datetime.strptime(pr["creationDate"], "%Y-%m-%dT%H:%M:%S.%fZ").strftime("%m/%d/%Y %I:%M %p"))
    print("Description:", pr["description"])
    print("URL:", pr["url"])
    print("Status:", pr["status"])
    print("Source Branch:", pr["sourceRefName"])
    print("Target Branch:", pr["targetRefName"])
    print("Commits:")
    for commit in pr["commits"]:
        print("\tCommit ID:", commit["commitId"])
        print("\tAuthor:", commit["author"]["displayName"])
        print("\tDate:", datetime.strptime(commit["author"]["date"], "%Y-%m-%dT%H:%M:%SZ").strftime("%m/%d/%Y %I:%M %p"))
        print("\tMessage:", commit["comment"])
        print("\n")
    print("\n")
