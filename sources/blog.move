module rooch_blog::rooch_blog {
    use std::error;
    // use std::option;
    use std::signer;
    use std::string::String;
    use rooch_blog::article_create_logic;
    // use moveos_std::object_storage;
    // use moveos_std::storage_context;
    // use moveos_std::object_id::ObjectID;
    use moveos_std::storage_context::StorageContext;
    // use moveos_std::object::{Self, Object};

    use rooch_blog::article;

    const EID_DATA_TOO_LONG: u64 = 102;
    const EINAPPROPRIATE_VERSION: u64 = 103;
    const ENOT_GENESIS_ACCOUNT: u64 = 105;

    // === Initialize ===

    // Define a function that initialize the blog
    fun init_blog(storage_ctx: &mut StorageContext, account: &signer) {
        assert!(signer::address_of(account) == @rooch_blog, error::invalid_argument(ENOT_GENESIS_ACCOUNT));
        let _ = storage_ctx;
        let _ = account;
    }

    // The entry function that initializes.
    entry fun initialize(storage_ctx: &mut StorageContext, account: &signer) {
        init_blog(storage_ctx, account);
    }

    // === Create ===

    public entry fun create(
        storage_ctx: &mut StorageContext,
        account: &signer,
        title: String,
        body: String,
    ) {
        let article_created = article_create_logic::verify(
            storage_ctx,
            account,
            title,
            body,
        );
        let article_obj = article_create_logic::mutate(
            storage_ctx,
            &article_created,
        );
        article::set_article_created_id(&mut article_created, article::id(&article_obj));
        article::add_article(storage_ctx, article_obj);
        article::emit_article_created(storage_ctx, article_created);
    }
}
