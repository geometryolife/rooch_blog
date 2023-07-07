module rooch_blog::article_create_logic {
    use std::string::String;

    use moveos_std::object::Object;
    use moveos_std::storage_context::StorageContext;
    use rooch_blog::article;
    use rooch_blog::article_created;

    // friend rooch_blog::article_aggregate;
    // friend rooch_blog::rooch_blog;
    // friend rooch_blog::blog;

    public fun verify(
        storage_ctx: &mut StorageContext,
        account: &signer,
        title: String,
        body: String,
    ): article::ArticleCreated {
        let _ = storage_ctx;
        let _ = account;
        article::new_article_created(
            title,
            body,
        )
    }

    public fun mutate(
        storage_ctx: &mut StorageContext,
        article_created: &article::ArticleCreated,
    ): Object<article::Article> {
        let title = article_created::title(article_created);
        let body = article_created::body(article_created);
        article::create_article(
            storage_ctx,
            title,
            body,
        )
    }
}
