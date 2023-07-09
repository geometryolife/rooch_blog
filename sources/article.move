module rooch_blog::article {
    use moveos_std::event;
    use moveos_std::object::{Self, Object};
    use moveos_std::object_id::ObjectID;
    use moveos_std::object_storage;
    use moveos_std::storage_context::{Self, StorageContext};
    use moveos_std::tx_context;
    use std::error;
    use std::option;
    use std::signer;
    use std::string::String;
    friend rooch_blog::rooch_blog;

    const EID_DATA_TOO_LONG: u64 = 102;
    const EINAPPROPRIATE_VERSION: u64 = 103;
    const ENOT_GENESIS_ACCOUNT: u64 = 105;

    public fun initialize(storage_ctx: &mut StorageContext, account: &signer) {
        assert!(signer::address_of(account) == @rooch_blog, error::invalid_argument(ENOT_GENESIS_ACCOUNT));
        let _ = storage_ctx;
        let _ = account;
    }

    // 定义文章的结构，后边被 `&Object<>` 包裹后，成为了对象的值，对象的值必须是对象的最后一个字段
    // 对象是一个特殊的结构体，由对象 ID、对象拥有者的地址、对象的值组成
    // 对象没有任何能力（ability），不能被丢弃、复制、存储
    // 因此，在使用的过程中需要传递，对象的可变引用或不可变引用
    struct Article has key {
        version: u64,
        title: String,
        body: String,
    }

    /// get object id
    // 这个函数获取对象的 ID，不涉及修改，所以参数传递文章对象的不可变引用
    // object 模块包含对象结构体的定义，以及操作对象结构体的函数
    // `object::id` 获取对象的 `ObjectID`，目前的 ObjectID 是一个地址
    public fun id(article_obj: &Object<Article>): ObjectID {
        object::id(article_obj)
    }

    /// 获取 Article 对象的版本
    // 传递文章对象的不可变引用，返回一个 u64 的文章版本值
    public fun version(article_obj: &Object<Article>): u64 {
        // borrow 获取对象的值，再通过点运算，获取对象值（Article）中的版本
        object::borrow(article_obj).version
    }

    /// 获取 Article 对象的标题
    // 传递文章对象的不可变引用，返回一个 String 类型
    public fun title(article_obj: &Object<Article>): String {
        // borrow 获取对象的值，再通过点运算，获取对象值（Article）中的标题
        object::borrow(article_obj).title
    }

    /// 设置 Article 对象的标题
    // 传递文章对象的可变引用和一个 String 类型值（文章标题）
    public(friend) fun set_title(article_obj: &mut Object<Article>, title: String) {
        // borrow_mut 获取对象的可变值，再通过点运算，获取对象可变值（Article）中的标题，通过赋值来修改
        object::borrow_mut(article_obj).title = title;
    }

    /// 获取 Article 对象的正文
    // 传递文章对象的不可变引用，返回一个 String 类型
    public fun body(article_obj: &Object<Article>): String {
        // borrow 获取对象的值，再通过点运算，获取对象值（Article）中的正文
        object::borrow(article_obj).body
    }

    /// 设置 Article 对象的正文
    // 传递文章对象的可变引用和一个 String 类型值（文章正文）
    public(friend) fun set_body(article_obj: &mut Object<Article>, body: String) {
        // borrow_mut 获取对象的可变值，再通过点运算，获取对象可变值（Article）中的正文，通过赋值来修改
        object::borrow_mut(article_obj).body = body;
    }

    /// 定义新建文章的函数
    // 新建文章，传递标题、正文参数，返回一个 Article 结构体，版本号设置为零
    fun new_article(
        _tx_ctx: &mut tx_context::TxContext,
        title: String,
        body: String,
    ): Article {
        // TODO 删除判断逻辑
        assert!(std::string::length(&title) <= 200, EID_DATA_TOO_LONG);
        assert!(std::string::length(&body) <= 2000, EID_DATA_TOO_LONG);
        Article {
            version: 0,
            title,
            body,
        }
    }

    // 定义创建文章的事件
    // id 创建文章的对象 ID，对象 ID 底层是地址，用来标识创建文章的地址
    // title
    // body
    struct ArticleCreatedEvent has key {
        // TODO 直接使用 ObjectID
        id: option::Option<ObjectID>,
        title: String,
        body: String,
    }

    /// 获取创建文章事件的 ID
    // 这个函数获取创建文章事件的 id，参数传入创建文章事件的不可变引用，返回对象 ID（底层是 address）
    public fun article_created_id(article_created: &ArticleCreatedEvent): option::Option<ObjectID> { // TODO 去掉 Option 包裹
        article_created.id
    }

    /// 设置创建文章事件的 ID
    // 这个函数设置创建文章事件的 id，参数传入创建文章事件的可变引用和对象 ID
    public(friend) fun set_article_created_id(article_created: &mut ArticleCreatedEvent, id: ObjectID) {
        // 获取 ArticleCreatedEvent 可变引用的 id，通过赋值修改 id
        article_created.id = option::some(id);
    }

    /// 获取创建文章事件的标题
    // 传入创建文章事件的不可变引用，返回文章的标题
    public fun article_created_title(article_created: &ArticleCreatedEvent): String {
        // 通过成员运算获取文章的标题
        article_created.title
    }

    /// 获取创建文章事件的正文
    // 传入创建文章事件的不可变引用，返回文章的正文
    public fun article_created_body(article_created: &ArticleCreatedEvent): String {
        // 通过成员运算获取文章的正文
        article_created.body
    }

    /// 定义创建文章事件的函数
    // 传入文章的标题和正文，返回创建文章的事件
    public fun new_article_created(
        title: String,
        body: String,
    ): ArticleCreatedEvent {
        ArticleCreatedEvent {
            id: option::none(), // TODO 换成 ObjectID
            title,
            body,
        }
    }

    struct ArticleUpdatedEvent has key {
        id: ObjectID,
        version: u64,
        title: String,
        body: String,
    }

    public fun article_updated_id(article_updated: &ArticleUpdatedEvent): ObjectID {
        article_updated.id
    }

    public fun article_updated_title(article_updated: &ArticleUpdatedEvent): String {
        article_updated.title
    }

    public fun article_updated_body(article_updated: &ArticleUpdatedEvent): String {
        article_updated.body
    }

    public(friend) fun new_article_updated(
        article_obj: &Object<Article>,
        title: String,
        body: String,
    ): ArticleUpdatedEvent {
        ArticleUpdatedEvent {
            id: id(article_obj),
            version: version(article_obj),
            title,
            body,
        }
    }

    struct ArticleDeletedEvent has key {
        id: ObjectID,
        version: u64,
    }

    public fun article_deleted_id(article_deleted: &ArticleDeletedEvent): ObjectID {
        article_deleted.id
    }

    public fun new_article_deleted(
        article_obj: &Object<Article>,
    ): ArticleDeletedEvent {
        ArticleDeletedEvent {
            id: id(article_obj),
            version: version(article_obj),
        }
    }

    public fun create_article(
        storage_ctx: &mut StorageContext,
        title: String,
        body: String,
    ): Object<Article> {
        let tx_ctx = storage_context::tx_context_mut(storage_ctx);
        let article = new_article(
            tx_ctx,
            title,
            body,
        );
        let obj_owner = tx_context::sender(tx_ctx);
        let article_obj = object::new(
            tx_ctx,
            obj_owner,
            article,
        );
        article_obj
    }

    public(friend) fun update_version_and_add(storage_ctx: &mut StorageContext, article_obj: Object<Article>) {
        object::borrow_mut(&mut article_obj).version = object::borrow( &mut article_obj).version + 1;
        //assert!(object::borrow(&article_obj).version != 0, EINAPPROPRIATE_VERSION);
        private_add_article(storage_ctx, article_obj);
    }

    public(friend) fun remove_article(storage_ctx: &mut StorageContext, obj_id: ObjectID): Object<Article> {
        let obj_store = storage_context::object_storage_mut(storage_ctx);
        object_storage::remove<Article>(obj_store, obj_id)
    }

    public(friend) fun add_article(storage_ctx: &mut StorageContext, article_obj: Object<Article>) {
        assert!(object::borrow(&article_obj).version == 0, EINAPPROPRIATE_VERSION);
        private_add_article(storage_ctx, article_obj);
    }

    fun private_add_article(storage_ctx: &mut StorageContext, article_obj: Object<Article>) {
        assert!(std::string::length(&object::borrow(&article_obj).title) <= 200, EID_DATA_TOO_LONG);
        assert!(std::string::length(&object::borrow(&article_obj).body) <= 2000, EID_DATA_TOO_LONG);
        let obj_store = storage_context::object_storage_mut(storage_ctx);
        object_storage::add(obj_store, article_obj);
    }

    public fun get_article(storage_ctx: &mut StorageContext, obj_id: ObjectID): Object<Article> {
        remove_article(storage_ctx, obj_id)
    }

    public fun return_article(storage_ctx: &mut StorageContext, article_obj: Object<Article>) {
        private_add_article(storage_ctx, article_obj);
    }

    public(friend) fun drop_article(article_obj: Object<Article>) {
        let (_id, _owner, article) =  object::unpack(article_obj);
        let Article {
            version: _version,
            title: _title,
            body: _body,
        } = article;
    }

    public(friend) fun emit_article_created(storage_ctx: &mut StorageContext, article_created: ArticleCreatedEvent) {
        event::emit_event(storage_ctx, article_created);
    }

    public(friend) fun emit_article_updated(storage_ctx: &mut StorageContext, article_updated: ArticleUpdatedEvent) {
        event::emit_event(storage_ctx, article_updated);
    }

    public(friend) fun emit_article_deleted(storage_ctx: &mut StorageContext, article_deleted: ArticleDeletedEvent) {
        event::emit_event(storage_ctx, article_deleted);
    }
}
