# Description
#   hubot scripts for restarting jobs
#
# Commands:
#   *hubot travis <REPO> <JOB>* - *Restart travis jobs `hubot travis jsk-ros-pkg/jsk_travis 100.1`*
#   *hubot docker* - *Restart docker on jenkins DO NOT RUN THIS COMMAND. IT CANCELS ALL TRAVIS JOBS.*

child_process = require 'child_process'

module.exports = (robot) ->
  robot.respond /travis\s+(.*)\s+(.*)$/i, (msg) ->
    repo = msg.match[1]
    job = msg.match[2]
    pro = ""
    login_token = process.env.okada_TOKEN
    if repo.match(/fkanehiro\/hrpsys-base/)
        token = process.env.kanehiro_TOKEN
    else if repo.match(/start-jsk\/rtmros_hrp2/) # private repository
        token = process.env.okada_pro_TOKEN
        login_token = process.env.okada_pro_TOKEN
        pro = "--pro"
    else
        token = process.env.okada_TOKEN
    console.log("restarting #{repo} #{job} #{token}")
    child_process.exec "travis login #{pro} --token #{login_token} --github-token #{process.env.okada_github_TOKEN}; travis restart #{pro} --token #{token} -r #{repo} #{job}", (error1, stdout1, stderr1) ->
      stdout1 = stdout1.replace(/\n$/, "")
      console.log("restarted ... error : " + error1 + ", stdout : " + stdout1 + ", stderr : " + stderr1)
      child_process.exec "travis open #{pro} -r #{repo} #{job} --print", (error2, stdout2, stderr2) ->
        stdout2 = stdout2.replace(/\n$/, "")
        console.log("web view : " + error2 + ", stdout : " + stdout2 + ", stderr : " + stderr2)
        if !error1
          output = "job #{job}(#{stdout2}) has been #{stdout1}"
          console.log(output)
          msg.send output
        else
          msg.send "fail to restart travis #{stdout1}, #{stderr1}"
          console.log(error1)
          console.log(stderr1)
          console.log(stdout1)

  robot.respond /docker/i, (msg) ->
    child_process.exec "sudo service docker restart", (error1, stdout1, stderr1) ->
      stdout1 = stdout1.replace(/\n$/, "")
      console.log("restarted ... error : " + error1 + ", stdout : " + stdout1 + ", stderr : " + stderr1)
      stdout1 = stdout1.replace(/\n$/, "")
      if !error1
        output = "docker has been restarted #{stdout1}"
        console.log(output)
        msg.send output
      else
        msg.send "fail to restart docker #{stdout1}, #{stderr1}"
        console.log(error1)
        console.log(stderr1)
        console.log(stdout1)


