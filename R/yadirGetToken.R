yadirGetToken <-
function(){
  browseURL("https://oauth.yandex.ru/authorize?response_type=token&client_id=3741a6d5d2454745867cd93fd191f6d2")
  token <- readline(prompt = "Enter your token: ")
  return(token)
}
