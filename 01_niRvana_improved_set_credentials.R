
# Improved set_credentials()
# 1) Input box also for username
# 2) Checks that username/password is correct by trying to download a little data

library(svDialogs)


set_credentials <- function () {
  passphrase <- "NIVA knows water"
  db_username <<- dlg_input("Input your username (three capital letters)", "DHJ")$res
  db_privkey <<- sodium::keygen()
  db_pubkey <<- sodium::pubkey(db_privkey)
  db_pwd <<- sodium::simple_encrypt(serialize(getPass::getPass(paste0("Please write the password for user ", 
                                                                      db_username, ": ")), NULL), db_pubkey)
  x <- try(get_nivabase_data("select * from NIVADATABASE.STATION_TYPES where rownum < 2" ))
  if (class(x) %in% "data.frame"){
    cat("Username/password successfully set for the rest of this R session\n")
  } else {
    cat("====================================================================================================\n")
    cat("Username/password is not correct. Please try again. The password may differ from your NIVA password\n")
    cat("====================================================================================================\n")
  }
  invisible(NULL)
  }


set_credentials_OLD <- function(){
  passphrase <- "NIVA knows water"
  db_username <<- readline("Please write your username (capital letters; push <enter> to finish): ")
  db_privkey <<- sodium::keygen()
  db_pubkey <<- sodium::pubkey(db_privkey)
  db_pwd <<- sodium::simple_encrypt(serialize(getPass::getPass(paste0("Please write the password for user ", 
                                                                      db_username, ": ")), NULL), db_pubkey)
  invisible(NULL)
}
