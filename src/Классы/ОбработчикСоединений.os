Перем ПроверкиПроксиСервера Экспорт;
Перем АдресСервера Экспорт;
Перем ПортСервера Экспорт;
Перем ПриветствиеХранилища;
Перем ПустыеДД;

&Желудь
Процедура ПриСозданииОбъекта()
	ПриветствиеХранилища = ПолучитьДвоичныеДанныеИзHexСтроки("53F5C61A7B");
	ПустыеДД = ПолучитьДвоичныеДанныеИзHexСтроки("");
КонецПроцедуры

Процедура ОбработатьСоединение(Соединение_Конфигуратор) Экспорт
	Соединение_Хранилище = Неопределено;
	Пока Соединение_Конфигуратор.Активно Цикл
		Если ИзКонфигуратораВХранилище(Соединение_Конфигуратор, Соединение_Хранилище) Тогда
			ИзХранилищаВКонфигуратор(Соединение_Конфигуратор, Соединение_Хранилище);
			ПостОбработкаПомещенияВХранилище();
		КонецЕсли;
	КонецЦикла;
	Соединение_Конфигуратор.Закрыть();
	Соединение_Хранилище.Закрыть();
КонецПроцедуры

Функция ИзКонфигуратораВХранилище(Соединение_Конфигуратор, Соединение_Хранилище)
	ДанныеСоединения = Неопределено;
	ЕстьПодключениеКХранилищу = Соединение_Хранилище <> Неопределено;
	Если НЕ ЕстьПодключениеКХранилищу Тогда
		ИнициализироватьСоединениеСХранилищем(Соединение_Конфигуратор, Соединение_Хранилище, ДанныеСоединения);
	КонецЕсли;
	ЭтоКонецСообщения = Ложь;
	ЭтоПинг = Ложь;
	Пока НЕ ЭтоКонецСообщения Цикл
		Если ЕстьПодключениеКХранилищу Тогда
			ДанныеСоединения = Соединение_Конфигуратор.ПрочитатьДвоичныеДанные();
		Иначе
			ЕстьПодключениеКХранилищу = Истина;
		КонецЕсли;
		ЭтоПинг = ОбработкаДанных.ЭтоПинг(ДанныеСоединения);
		Если НЕ ЭтоПинг Тогда
			ПараметрыЗапроса = ОбработкаДанных.ПолучитьПараметрыЗапроса(ДанныеСоединения);
			Если ПараметрыЗапроса <> Неопределено
				И ПараметрыЗапроса.Проверять = Истина Тогда
				ПродолжитьСоединение = ОбработатьПроверяемыйЗапрос(Соединение_Конфигуратор, Соединение_Хранилище, ДанныеСоединения);
				Возврат ПродолжитьСоединение;
			КонецЕсли;
		КонецЕсли;
		Соединение_Хранилище.ОтправитьДвоичныеДанные(ДанныеСоединения);
		Если ЭтоПинг Тогда
			Соединение_Конфигуратор.ОтправитьДвоичныеДанные(ПустыеДД);
			ЭтоКонецСообщения = Истина;
		Иначе
			ЭтоКонецСообщения = ОбработкаДанных.ЕстьКонецСообщения(ДанныеСоединения);
		КонецЕсли;
	КонецЦикла;
	Возврат НЕ ЭтоПинг;
КонецФункции

Функция ОбработатьПроверяемыйЗапрос(Соединение_Конфигуратор, Соединение_Хранилище, ДанныеСоединения)
	МассивДДЗапроса = Новый Массив;
	МассивДДЗапроса.Добавить(ДанныеСоединения);
	Пока НЕ ОбработкаДанных.ЕстьКонецСообщения(ДанныеСоединения) Цикл
		ДанныеСоединения = Соединение_Конфигуратор.ПрочитатьДвоичныеДанные();
		МассивДДЗапроса.Добавить(ДанныеСоединения);
	КонецЦикла;
	ДанныеСоединения = СоединитьДвоичныеДанные(МассивДДЗапроса);
	ПараметрыЗапроса = ОбработкаДанных.ПолучитьПараметрыЗапроса(ДанныеСоединения);
	ТекстОшибки = "";
	Попытка
		Если ПараметрыЗапроса.ИмяМетода = "DevDepot_commitObjects" Тогда
			ТекстОшибки = ПроверкиПроксиСервера.ОбработкаПомещенияВХранилище(ПараметрыЗапроса);
		ИначеЕсли ПараметрыЗапроса.ИмяМетода = "DevDepot_changeVersion" Тогда
			ТекстОшибки = ПроверкиПроксиСервера.ОбработкаИзмененияВерсииХранилища(ПараметрыЗапроса);
		КонецЕсли;
	Исключение
		ТекстОшибки = СтрШаблон("Ошибка вызова функции в файле ""ПроверкиПроксиСервера.os"": %1", ОписаниеОшибки());
	КонецПопытки;
	ЕстьОшибка = НЕ ПустаяСтрока(ТекстОшибки);
	Если ЕстьОшибка Тогда
		ДД = ОбработкаДанных.ПолучитьДвоичныеДанныеОтветаОшибки(ТекстОшибки);
		Соединение_Конфигуратор.ОтправитьДвоичныеДанные(ДД);
		Возврат Ложь;
	Иначе
		Для Каждого ДанныеСоединения Из МассивДДЗапроса Цикл
			Соединение_Хранилище.ОтправитьДвоичныеДанные(ДанныеСоединения);
		КонецЦикла;
	КонецЕсли;
	Возврат НЕ ЕстьОшибка;
КонецФункции

Процедура ИзХранилищаВКонфигуратор(Соединение_Конфигуратор, Соединение_Хранилище)
	ЭтоКонецСообщения = Ложь;
	Пока НЕ ЭтоКонецСообщения Цикл
		ДанныеСоединения = Соединение_Хранилище.ПрочитатьДвоичныеДанные();
		Соединение_Конфигуратор.ОтправитьДвоичныеДанные(ДанныеСоединения);
		ЭтоКонецСообщения = ОбработкаДанных.ЕстьКонецСообщения(ДанныеСоединения);
	КонецЦикла;
КонецПроцедуры

Процедура ИнициализироватьСоединениеСХранилищем(Соединение_Конфигуратор, Соединение_Хранилище, ДанныеПервогоЗапроса)
	Соединение_Конфигуратор.ОтправитьДвоичныеДанные(ПриветствиеХранилища);
	ДанныеПервогоЗапроса = Соединение_Конфигуратор.ПрочитатьДвоичныеДанные();
	Соединение_Хранилище = Новый TCPСоединение(АдресСервера, ПортСервера);
	Соединение_Хранилище.ПрочитатьДвоичныеДанные();
КонецПроцедуры

Процедура ПостОбработкаПомещенияВХранилище()
	РезультатБулево = ПроверкиПроксиСервера.ПостОбработкаПомещенияВХранилище();
КонецПроцедуры
