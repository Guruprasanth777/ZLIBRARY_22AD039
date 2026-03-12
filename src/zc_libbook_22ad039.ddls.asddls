@EndUserText.label: 'Library Book Projection'
@Metadata.allowExtensions: true
define root view entity ZC_LIBBOOK_22AD039
  provider contract transactional_query
  as projection on ZI_LIBBOOK_22AD039
{
  key book_id,
      book_name,
      author,
      category,
      available
}
