@EndUserText.label : 'Library Book Interface View'
define root view entity ZI_LIBBOOK_22AD039
  as select from zlibbook_22ad039
{
  key book_id,
      book_name,
      author,
      category,
      available
}
