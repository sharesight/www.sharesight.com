// Copy the wordpress URL field into the urlSlug field for all blog posts
// that have a wordpress URL set, and no Url Slug set.
// Should be run with the contentful migration tool: https://github.com/contentful/contentful-migration

module.exports = function (migration) {
  migration.transformEntries({
    contentType: 'post',
    from: ['wordpress_url', 'urlSlug'],
    to: ['urlSlug'],
    transformEntryForLocale: function (fromFields, currentLocale) {
      const wordPressUrl = fromFields.wordpressUrl;
      if (wordPressUrl == null || wordPressUrl == undefined || wordPressUrl == "") {
        console.log("No wordpress url; nothing to do");
        return;
      }

      const urlSlug = fromFields.urlSlug;
      if (urlSlug != null) {
        console.log("Refusing to update existing slug");
        return;
      }

      const wordPressUrlValue = wordPressUrl[currentLocale].toString();
      const newSlug = wordPressUrlValue.match(/\/\/([\S]+)/)[1];
      console.log(`Migrating to new slug: ${newSlug} from: ${wordPressUrlValue}`)
      return { urlSlug: newSlug};
    }
  });
};
