# Description
#   hubot scripts for auto editing opened issue.
#
# Features:
#   * auto labeling (ex. if title is "[bug] Hogehoge", add label "bug")


url = require('url')

module.exports = (robot) ->

    github = require("githubot")(robot)
    url_api_base = "https://api.github.com"

    owner = "jsk-ros-pkg"
    channel_name = "github"

    # Auto labeling by issue title
    robot.router.post "/github/github-issue-autoedit", (req, res) ->
        data = req.body

        if data.action not in ['opened', 'reopened']
            return res.end ""

        issue = data.issue
        repo = data.repository

        match = /^\[(.*)\]/.exec(issue.title)
        label = match[1]

        if label:
          url = "#{url_api_base}/repos/#{owner}/#{repo.name}/issues/#{issue.number}"
          data = { "label": label }
          github.patch url, data, (issue, error) ->
            if ! issue?
              robot.messageRoom channel_name, "Error occured on issue \##{issue.number} auto labeling."
              return
            body = "Added label #{label} to *\##{pullreq.number}*."
            robot.messageRoom channel_name, body
            res.end ""
