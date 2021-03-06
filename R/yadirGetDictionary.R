yadirGetDictionary <- function(DictionaryName = "GeoRegions", Language = "ru", login = NULL, token = NULL){
  #�������� ������� ������ � ������
  if(is.null(login)|is.null(token)) {
    stop("You must enter login and API token!")
  }
  
  #�������� ����� �� ������� �������� �����������
  if(!DictionaryName %in% c("Currencies",
                            "MetroStations",
                            "GeoRegions",
                            "TimeZones",
                            "Constants",
                            "AdCategories",
                            "OperationSystemVersions",
                            "ProductivityAssertions",
                            "SupplySidePlatforms",
                            "Interests")){
    stop("Error in DictionaryName, select one of Currencies, MetroStations, GeoRegions, TimeZones, Constants, AdCategories, OperationSystemVersions, ProductivityAssertions, SupplySidePlatforms, Interests")
  }
  
  queryBody <- paste0("{
                      \"method\": \"get\",
                      \"params\": {
                      \"DictionaryNames\": [ \"",DictionaryName,"\" ]
}
}")
  
  #�������� ������� �� ������
  answer <- POST("https://api.direct.yandex.com/json/v5/dictionaries", body = queryBody, add_headers(Authorization = paste0("Bearer ",token), 'Accept-Language' = Language, "Client-Login" = login[1]))
  #�������� ���������� �� ������
  stop_for_status(answer)
  
  dataRaw <- content(answer, "parsed", "application/json")
  
  if(length(dataRaw$error) > 0){
    stop(paste0(dataRaw$error$error_string, " - ", dataRaw$error$error_detail))
  }
  
  #����������� ����� � data frame
  
  #������� ����������� ��������
  if(DictionaryName == "GeoRegions"){
  dictionary_df <- data.frame()

  for(dr in 1:length(dataRaw$result[[1]])){
    dictionary_df_temp <- data.frame(GeoRegionId = dataRaw$result[[1]][[dr]]$GeoRegionId,
                                     ParentId = ifelse(is.null(dataRaw$result[[1]][[dr]]$ParentId),NA , dataRaw$result[[1]][[dr]]$ParentId),
                                     GeoRegionType = dataRaw$result[[1]][[dr]]$GeoRegionType,
                                     GeoRegionName = dataRaw$result[[1]][[dr]]$GeoRegionName)
    dictionary_df <- rbind(dictionary_df, dictionary_df_temp)
    
  }}

  #������� ����������� �����
  if(DictionaryName == "Currencies"){
    dictionary_df <- data.frame()
  for(dr in 1:length(dataRaw$result[[1]])){
    dictionary_df_temp <- data.frame(Cur = dataRaw$result[[1]][[dr]]$Currency, as.data.frame(do.call(rbind.data.frame, dataRaw$result[[1]][[dr]]$Properties), row.names = NULL, stringsAsFactors = F))
    dictionary_df <- rbind(dictionary_df, dictionary_df_temp)
  }
    dictionary_df_cur <- data.frame()
    #����������� ���������� �����
    for(curlist in unique(dictionary_df$Cur)){
      dictionary_df_temp <- data.frame(Cur = curlist,
                                       FullName = dictionary_df[dictionary_df$Cur == curlist & dictionary_df$Name == "FullName",3],
                                       Rate = dictionary_df[dictionary_df$Cur == curlist & dictionary_df$Name == "Rate",3],
                                       RateWithVAT = dictionary_df[dictionary_df$Cur == curlist & dictionary_df$Name == "RateWithVAT",3])
      dictionary_df_cur <- rbind(dictionary_df_cur,dictionary_df_temp)
    }
    dictionary_df <- dictionary_df_cur
  }
  
  #������� ����������� Interests
  if(DictionaryName == "Interests"){
    dictionary_df <- data.frame()
    for(dr in 1:length(dataRaw$result[[1]])){
      dictionary_df_temp <- data.frame(Name = dataRaw$result[[1]][[dr]]$Name,
                                       ParentId = ifelse(is.null(dataRaw$result[[1]][[dr]]$ParentId),NA , dataRaw$result[[1]][[dr]]$ParentId),
                                       InterestId = dataRaw$result[[1]][[dr]]$InterestId,
                                       IsTargetable = dataRaw$result[[1]][[dr]]$IsTargetable)
      dictionary_df <- rbind(dictionary_df, dictionary_df_temp)
    }
  }
  
  #������� ��������� ������������ �� ����������� ����������
  if(! DictionaryName %in% c("Currencies","GeoRegions","Interests")){
    dictionary_df <- do.call(rbind.data.frame, dataRaw$result[[1]])
    }
  
  #������� ���������� � ������ ������� � � ���������� ������
  packageStartupMessage("���������� ������� ��������!", appendLF = T)
  packageStartupMessage(paste0("����� ������� � : " ,answer$headers$`units-used-login`), appendLF = T)
  packageStartupMessage(paste0("�-�� ������ �������������� ��� ���������� �������: " ,strsplit(answer$headers$units, "/")[[1]][1]), appendLF = T)
  packageStartupMessage(paste0("��������� ������� ��������� ������ ������: " ,strsplit(answer$headers$units, "/")[[1]][2]), appendLF = T)
  packageStartupMessage(paste0("�������� ����� ������: " ,strsplit(answer$headers$units, "/")[[1]][3]), appendLF = T)
  packageStartupMessage(paste0("���������� ������������� ������� ������� ���������� ��������� ��� ��������� � ������ ���������: ",answer$headers$requestid), appendLF = T)
  
  #���������� ��������� � ���� Data Frame
  return(dictionary_df)
}

