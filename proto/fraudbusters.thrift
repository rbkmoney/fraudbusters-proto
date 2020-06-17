include 'base.thrift'
include 'domain.thrift'

/**
 * Сервис поиска мошеннических операций.
 */

namespace java com.rbkmoney.damsel.fraudbusters
namespace erlang fraudbusters

typedef string ID

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

// Модель комманды
struct Command {
    1: required CommandType command_type
    2: required CommandBody command_body
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

struct FraudInfo {
    1: required ID tempalte_id
    2: optional string  description
}

struct FraudPayment {
    1:  required ID id
    2:  required base.Timestamp last_change_time
    3:  required ID party_id
    4:  required ID shop_id
    5:  required domain.Cash cost
    6:  required domain.Payer payer
    7:  required PaymentStatus status
    8:  optional string rrn
    9:  optional domain.PaymentRoute route
    10: required FraudInfo fraud_info
}

struct BankCard {
    1: required string bin
    2: required string masked_pan
    3: required string card_token
    4: required string payment_system
}

struct ProviderInfo {
    1: optional string country
    2: required ID provider_id
    3: required ID terminal_id
}

struct AdditionalInfo {
    1:  optional string ip
    2:  optional string fingerprint
    3:  optional string email
}

struct MerchantInfo {
    1:  required ID party_id
    2:  required ID shop_id
}

union PaymentTool {
    1: BankCard bank_card
}

union ReferenceInfo {
    1: MerchantInfo merchant_info
}

struct Error {
    1:  optional string error_reason
    2:  optional string error_code
}

struct Payment {
    1:  required ID id
    2:  required base.Timestamp event_time
    3:  required ReferenceInfo reference_info
    4:  required PaymentTool payment_tool
    5:  required domain.Cash cost
    6:  required ProviderInfo provider_info
    7:  required PaymentStatus status
    8:  optional Error error
    9:  required AdditionalInfo additional_info
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
    5:  required PaymentTool payment_tool
    6:  required domain.Cash cost
    7:  required ProviderInfo provider_info
    8:  required RefundStatus status
    9:  optional Error error
    10:  required AdditionalInfo additional_info
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
    5:  required PaymentTool payment_tool
    6:  required domain.Cash cost
    7:  required ProviderInfo provider_info
    8:  required ChargebackStatus status
    9:  required ChargebackCategory category
    10:  required string chargeback_code
    11:  required AdditionalInfo additional_info
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

    void insertRefunds(1: list<Refund> refunds)

    void insertChargebacks(1: list<Chargeback> chargebacks)

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