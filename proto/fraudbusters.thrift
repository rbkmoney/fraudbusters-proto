/**
 * Сервис поиска мошеннических операций.
 */

namespace java com.rbkmoney.damsel.fraudbusters
namespace erlang fraudbusters

typedef string ID

exception ListNotFound {}

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

struct MerchantType {
    1: required ID party_id
    2: optional ID shop_id
}

struct GlobalType {}
struct DefaultType {}

/**
* MerchantType - привязка к конкретному магазину
* GlobalType - привязка к общему для всех магазинов шаблону
* DefaultType - привязка для только активированных магазинов до момента заведения конкретной привязки MerchantType
**/
union TemplateReferenceType {
    1: MerchantType merchant_type
    2: GlobalType global_type
    3: DefaultType default_type
}

// Модель связки шаблона с проверяемым субъектом
struct TemplateReference {
    // Идентификатор привязываемого шаблона
    1: required ID template_id
    // Тип связки
    2: required TemplateReferenceType type
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

