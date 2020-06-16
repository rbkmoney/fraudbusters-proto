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

/**
* Интерфейс для управления FraudoPayment
*/
service PaymentService {

    /**
    * Проверяет компиляцию шаблонов на актуальной версии языка
    **/
    ValidateTemplateResponse validateCompilationTemplate(1: list<Template> templates)

    void insertFraudPayments(1: list<FraudPayment> payments)

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