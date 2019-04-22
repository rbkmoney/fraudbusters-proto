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
}

// Модель комманды
struct Command {
    1: required CommandType commandType
    2: required CommandBody commandBody
}

// Модель шаблона
struct Template {
    // Уникальный идентификатор шаблона
    1: required ID id
    // Описние правил на языке fraudo
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