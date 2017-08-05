library(gmailr)


gmail_auth(scope = c("read_only", "modify", "compose", "full"), id = the$id,
           secret = the$secret, secret_file = NULL)


mime() %>%
  to("hanasakai@gmail.com") %>%
  from("hanasakai@gmail.com") %>%
  text_body("Gmailr is a very handy package!") -> text_msg

strwrap(as.character(text_msg))

create_draft(text_msg)

#############################################################################
install.packages(c("devtools", "rJython", "rJava", "rjson"))
library(devtools)
install_github("trinker/gmailR")
install_github("kbroman/mygmailR")

