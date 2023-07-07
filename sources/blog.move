module rooch_blog::rooch_blog {
    use std::error;
    use std::signer;
    use moveos_std::storage_context::StorageContext;

    const EID_DATA_TOO_LONG: u64 = 102;
    const EINAPPROPRIATE_VERSION: u64 = 103;
    const ENOT_GENESIS_ACCOUNT: u64 = 105;

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

}
