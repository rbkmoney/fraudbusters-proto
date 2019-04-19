/**
 * Сервис поиска мошеннических операций.
 */

namespace java com.rbkmoney.damsel.fraudbusters
namespace erlang fraudbusters

typedef string ID

exception ListNotFound {}

enum Command {
    CREATE
    DELETE
}

// Модель шаблона
struct Template {
    // Уникальный идентификатор шаблона
    1: required ID id
    // Описние правил на языке fraudo
    2: required binary template
    // Комманда изменения шаблона
    3: required Command command
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