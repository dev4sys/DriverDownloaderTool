# #########################################################
# Common Function 
# #########################################################



function Test(){


$queue = [System.Collections.Queue]::new()


# unescaped HP Query
$unescapedsessionData = '{"productNameOid":"7343200","urlLanguage":"en","language":"en","osId":"792898937266030878164166465223921","countryCode":"us","platformId":"487192269364721453674728010296573","versionName":"Windows+10+(64-bit)","versionId":"792898937266030878164166465223921","osLanguageName":"en","osLanguageCode":"en","sku":"","productSeriesOid":"7343192","productSeriesName":"hp-elitebook-820-g2-notebook-pc"}'
# removed OS
$unescapedsessionData = '{"productNameOid":"7343200","urlLanguage":"en","language":"en","osId":"792898937266030878164166465223921","countryCode":"us","platformId":"487192269364721453674728010296573","productSeriesOid":"7343192","productSeriesName":"hp-elitebook-820-g2-notebook-pc"}'
# simplified
$unescapedsessionData = '{"productNameOid":"7343200","urlLanguage":"en","language":"en","osId":"792898937266030878164166465223921","countryCode":"us","productSeriesOid":"7343192","productSeriesName":"hp-elitebook-820-g2-notebook-pc"}'






}



















