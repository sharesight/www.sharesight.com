// Copy the wordpress URL field into the urlSlug field for all blog posts
// that have a wordpress URL set, and no Url Slug set.
// Should be run with the contentful migration tool: https://github.com/contentful/contentful-migration

module.exports = function (migration) {
  migration.transformEntries({
    contentType: 'post',
    from: ['wordpress_url', 'urlSlug'],
    to: ['urlSlug'],
    transformEntryForLocale: function (fromFields, currentLocale) {
      const wordPressUrl = fromFields.wordpress_url;
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
      console.log("WordPressURL: " + wordPressUrlValue);

      const urlArray = wordPressUrlValue.split("/");
      const newSlug = urlArray[urlArray.length - 2]; // there is a trailing '/' on wordpress URL

      console.log(`Migrating to new slug: ${newSlug} from: ${wordPressUrlValue}`)
      return { urlSlug: newSlug};
    }
  });
};
