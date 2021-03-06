include 'base.thrift'
include 'domain.thrift'

/**
 * Сервис поиска мошеннических операций.
 */

namespace java com.rbkmoney.damsel.fraudbusters
namespace erlang fraudbusters

typedef string ID
typedef ID AccountID
typedef ID IdentityID
typedef ID WalletID
typedef i32 ProviderID
typedef i32 TerminalID

enum CommandType {
    CREATE
    DELETE
}

union CommandBody {
    1: Template template;
    2: TemplateReference reference;
    3: GroupReference group_reference;
    4: Group group;
    5: P2PGroupReference p2p_group_reference;
    6: P2PReference p2p_reference;
}

// Модель пользователя
struct UserInfo {
    1: required ID user_id
}

// Модель комманды
struct Command {
    1: required CommandType command_type
    2: required CommandBody command_body
    3: optional base.Timestamp command_time
    4: optional UserInfo user_info
}

// Модель шаблона
struct Template {
    // Уникальный идентификатор шаблона
    1: required ID id
    // Описание правил на языке fraudo
    2: required binary template
}

// Модель связки шаблона с проверяемым субъектом
struct TemplateReference {
    // Идентификатор party
    1: optional ID party_id
    // Идентификатор магазина
    2: optional ID shop_id
    // Идентификатор привязываемого шаблона
    3: required ID template_id
    // Признак глобальности (при значении true поля party_id и shop_id игнорируются)
    4: required bool is_global = false
}

// Модель связки шаблона с проверяемым субъектом
struct P2PReference {
    // Идентификатор кошелька
    1: optional ID identity_id
    // Идентификатор привязываемого шаблона
    2: required ID template_id
    // Признак глобальности (при значении true поля identity_id игнорируются)
    3: required bool is_global = false
}

// Модель связки шаблона с проверяемым субъектом
struct GroupReference {
    // Идентификатор party
    1: optional ID party_id
    // Идентификатор магазина
    2: optional ID shop_id
    // Идентификатор привязываемого шаблона
    3: required ID group_id
}


// Модель связки шаблона с проверяемым субъектом
struct P2PGroupReference {
    // Идентификатор кошелька
    1: optional ID identity_id
    // Идентификатор привязываемого шаблона
    2: required ID group_id
}

// Модель группы шаблонов
struct Group {
    // Идентификатор группы
    1: required ID group_id
    // Идентификаторы шаблонов входящих в группу
    2: required list<PriorityId> template_ids
}

// Модель приоритезированного идентификатора
struct PriorityId {
    // Приоритет
    1: required i64 priority
    // Идентификатор
    2: required ID id
}

// Модель ответа валидации, errors пустой если все темплейты валидные, приходят только проблемные темплейты
struct ValidateTemplateResponse {
    1: optional list<TemplateValidateError> errors
}

// Модель ошибки у каждого темплейта может быть несколько ошибок
struct TemplateValidateError {
    1: required ID id
    2: optional list<string> reason
}

enum PaymentStatus {
    processed
    captured
    failed
}

struct FraudPayment {
    1:  required ID id
    2:  required base.Timestamp event_time
    3:  optional string type
    4:  optional string comment
}

struct ProviderInfo {
    1: required ID provider_id
    2: required ID terminal_id
    3: optional string country
}

struct ClientInfo {
    1:  optional string ip
    2:  optional string fingerprint
    3:  optional string email
}

struct MerchantInfo {
    1:  required ID party_id
    2:  required ID shop_id
}

union ReferenceInfo {
    1: MerchantInfo merchant_info
}

struct Error {
    1:  required string error_code
    2:  optional string error_reason
}

enum PayerType {
    payment_resource
    customer
    recurrent
}

struct Payment {
    1:  required ID id
    2:  required base.Timestamp event_time
    3:  required ReferenceInfo reference_info
    4:  required domain.PaymentTool payment_tool
    5:  required domain.Cash cost
    6:  required ProviderInfo provider_info
    7:  required PaymentStatus status
    8:  optional Error error
    9:  required ClientInfo client_info
   10:  optional PayerType payer_type
   11:  optional bool mobile
   12:  optional bool recurrent
}

enum RefundStatus {
    succeeded
    failed
}

struct Refund {
    1:  required ID id
    2:  required ID payment_id
    3:  required base.Timestamp event_time
    4:  required ReferenceInfo reference_info
    5:  required domain.PaymentTool payment_tool
    6:  required domain.Cash cost
    7:  required ProviderInfo provider_info
    8:  required RefundStatus status
    9:  optional Error error
    10:  required ClientInfo client_info
    11:  optional PayerType payer_type
}

enum ChargebackStatus {
    accepted
    rejected
    cancelled
}

enum ChargebackCategory {
    fraud
    dispute
    authorisation
    processing_error
}

struct Chargeback {
    1:  required ID id
    2:  required ID payment_id
    3:  required base.Timestamp event_time
    4:  required ReferenceInfo reference_info
    5:  required domain.PaymentTool payment_tool
    6:  required domain.Cash cost
    7:  required ProviderInfo provider_info
    8:  required ChargebackStatus status
    9:  required ChargebackCategory category
    10:  required string chargeback_code
    11:  required ClientInfo client_info
    12:  optional PayerType payer_type
}

struct Withdrawal {
    1:  required ID id
    2:  required base.Timestamp event_time
    3:  required Resource destination_resource
    4:  required domain.Cash cost
    5:  required WithdrawalStatus status
    6:  required Account account
    7:  optional Error error
    8:  optional ProviderInfo provider_info
}

union Resource {
    1: domain.BankCard bank_card
    2: CryptoWallet crypto_wallet
    3: DigitalWallet digital_wallet
}

struct CryptoWallet {
    1: required string id
    2: required string currency
}

/**
 *  Электронный кошелёк
 */
struct DigitalWallet {
    1: required string id
    2: optional string digital_data_provider
}

struct Account {
    3: required AccountID id
    1: required IdentityID identity
    2: required domain.CurrencyRef currency
}

enum WithdrawalStatus {
    pending
    succeeded
    failed
}

struct PaymentInfo {
    1:  required ID id
    2:  required base.Timestamp event_time
    3:  required MerchantInfo merchant_info
    4:  required i64 amount
    5:  required string currency
    6:  optional string card_token
    7:  optional ClientInfo client_info
    8:  required PaymentStatus status
    9:  required Error error
    10: required string payment_system
    11: required string payment_country
    12: required string payment_tool
    13: required ProviderInfo provider
}

struct PaymentInfoResult {
    1:  required list<PaymentInfo> payments
    2:  optional ID continuation_id
}

struct Filter {
    1: optional string party_id
    2: optional string shop_id
    3: optional string payment_id
    4: optional string status
    5: optional string email
    6: optional string provider_country
    7: optional string card_token
    8: optional string fingerprint
    9: optional string terminal
    10: optional base.TimestampInterval interval
}

struct Page {
    1: required i64 size
    2: optional ID continuation_id
}

struct Sort {
    1: optional SortOrder order
    2: optional string field
}

enum SortOrder {
    ASC
    DESC
}

/**
* Исключение при вставке, в id приходит идентификатор записи из батча, начиная с которой записи не вставились
* во избежания дубликатов записей необходимо повторять только записи начиная с вернувшегося ID
*/
exception InsertionException {
    1: ID id
    2: string reason
}

/**
* Интерфейс для управления FraudoPayment
*/
service PaymentService {

    /**
    * Проверяет компиляцию шаблонов на актуальной версии языка
    **/
    ValidateTemplateResponse validateCompilationTemplate(1: list<Template> templates)

    void insertFraudPayments(1: list<FraudPayment> payments)

    void insertPayments(1: list<Payment> payments)
    throws (1: InsertionException ex1)

    void insertWithdrawals(1: list<Withdrawal> payments)
    throws (1: InsertionException ex1)

    void insertRefunds(1: list<Refund> refunds)
    throws (1: InsertionException ex1)

    void insertChargebacks(1: list<Chargeback> chargebacks)
    throws (1: InsertionException ex1)

}

/**
* Интерфейс для управления FraudoP2P
*/
service P2PService {

    /**
    * Проверяет компиляцию шаблонов на актуальной версии языка
    **/
    ValidateTemplateResponse validateCompilationTemplate(1: list<Template> templates)

}

/**
* Интерфейс для получения иторических данных
*/
service HistoricalDataService {

    /**
    * Получение исторических данных по платежам
    **/
    PaymentInfoResult getPayments(1: Filter filter, 2: Page page, 3: Sort sort)

}
