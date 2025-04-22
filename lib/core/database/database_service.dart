import 'dart:convert';

import 'package:postgres/postgres.dart';

class DatabaseService {
  final String _host;
  final String _database;
  final String _username;
  final String _password;
  final int _port;

  DatabaseService({
    String? host,
    String? database,
    String? username,
    String? password,
    int? port,
  })  : _host = host ?? '10.0.2.2',
        _database = database ?? 'neoflex_quest',
        _username = username ?? 'postgres',
        _password = password ?? 'password',
        _port = port ?? 5432;


  Future<PostgreSQLConnection> getConnection() async {
    final connection = PostgreSQLConnection(
      _host,
      _port,
      _database,
      username: _username,
      password: _password,
      timeoutInSeconds: 60,
      encoding: utf8,
      useSSL: false,
    );

    await Future.delayed(Duration(seconds: 5));
    try {
      await connection.open();
      return connection;
    } catch (e) {
      print('Connection error: $e');
      rethrow;
    }
  }

  Future<void> initDatabase() async {
    final connection = await getConnection();
    await connection.query('DISCARD ALL');
    try {
      await connection.transaction((ctx) async {
        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            password TEXT NOT NULL,
            email VARCHAR(100) UNIQUE,
            points INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS achievements (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            description TEXT NOT NULL,
            points_reward INTEGER NOT NULL,
            is_secret BOOLEAN DEFAULT FALSE,
            icon_path VARCHAR(100)
          )
        ''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS user_achievements (
            user_id INTEGER REFERENCES users(id),
            achievement_id INTEGER REFERENCES achievements(id),
            earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (user_id, achievement_id)
          )
        ''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS shop_items (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            price INTEGER NOT NULL,
            stock INTEGER,
            image_path VARCHAR(100)
          )
        ''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS purchases (
            id SERIAL PRIMARY KEY,
            user_id INTEGER REFERENCES users(id),
            item_id INTEGER REFERENCES shop_items(id),
            purchased_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            status VARCHAR(20) DEFAULT 'pending'
          )
        ''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS time_machine_questions (
            id SERIAL PRIMARY KEY,
            era VARCHAR(50) NOT NULL,
            question_text TEXT NOT NULL,
            correct_answer VARCHAR(255) NOT NULL,
            option1 VARCHAR(255),
            option2 VARCHAR(255),
            option3 VARCHAR(255),
            points INTEGER NOT NULL
          )
        ''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS user_answers (
            user_id INTEGER REFERENCES users(id),
            question_id INTEGER REFERENCES time_machine_questions(id),
            answer VARCHAR(255) NOT NULL,
            is_correct BOOLEAN NOT NULL,
            answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (user_id, question_id)
          )
        ''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS education_items (
            id SERIAL PRIMARY KEY,
            title VARCHAR(100) NOT NULL,
            short_description TEXT NOT NULL,
            full_description TEXT NOT NULL,
            correct_category VARCHAR(20) NOT NULL,
            points INTEGER NOT NULL
          )
        ''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS education_answers (
            user_id INTEGER REFERENCES users(id),
            item_id INTEGER REFERENCES education_items(id),
            selected_category VARCHAR(20) NOT NULL,
            is_correct BOOLEAN NOT NULL,
            answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (user_id, item_id)
          )
        ''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS public.test_attempts (
            user_id INTEGER REFERENCES users(id),
            era VARCHAR(50) NOT NULL,
            attempts_used INTEGER DEFAULT 0,
            last_attempt TIMESTAMP,
            PRIMARY KEY (user_id, era)
        )''');

        await ctx.execute('''
          CREATE TABLE IF NOT EXISTS education_attempts (
          user_id INTEGER REFERENCES users(id) PRIMARY KEY,
          attempts_used INTEGER DEFAULT 0,
          last_attempt TIMESTAMP,
          max_attempts INTEGER DEFAULT 3
        )''');
      });

      await _seedInitialData(connection);
    } finally {
      await connection.close();
    }
  }

  Future<void> _seedInitialData(PostgreSQLConnection connection) async {
    // Проверяем и добавляем достижения
    final achievements = await connection.query(
        'SELECT 1 FROM achievements LIMIT 1');
    if (achievements.isEmpty) {
      await connection.query('''
        INSERT INTO achievements (name, description, points_reward, is_secret, icon_path) VALUES
          ('Фанат мандаринок', 'Попытаться снять кожуру с мандаринки в Торговой точке', 10, true, 'assets/achievements/mandarin_fan.png'),
          ('Хронозавр', 'Пройти блок Машина времени на 100%', 50, false, 'assets/achievements/time_master.png'),
          ('Неопедия', 'Пройти блок Образовательные миссии на 100%', 50, false, 'assets/achievements/neo_pedia.png'),
          ('Аномалия', 'Пройти все временные точки в блоке Машина времени', 30, false, 'assets/achievements/anomaly.png'),
          ('Ответственный сортировщик', 'Расположить модули по контейнерам в блоке Образовательные миссии', 30, false, 'assets/achievements/sorter.png')
      ''');
    }

    // Проверяем и добавляем товары
    final shopItems = await connection.query(
        'SELECT 1 FROM shop_items LIMIT 1');
    if (shopItems.isEmpty) {
      await connection.query('''
        INSERT INTO shop_items (name, description, price, stock, image_path) VALUES
          ('Блок стикеров-закладок', 'Набор стикеров с фирменным дизайном', 50, 100, 'assets/shop/stickers.png'),
          ('Ручка + Фиолетовый блокнот', 'Фирменная ручка и блокнот', 100, 50, 'assets/shop/notebook_purple.png'),
          ('Ручка + Блокнот с Неончиком', 'Фирменная ручка и блокнот с маскотом', 150, 30, 'assets/shop/notebook_mascot.png'),
          ('Мягкий антистресс', 'Антистрессовая игрушка', 200, 20, 'assets/shop/stress_toy.png'),
          ('Бутылка', 'Фирменная бутылка для воды', 250, 15, 'assets/shop/bottle.png'),
          ('Термокружка', 'Термокружка с логотипом', 300, 10, 'assets/shop/thermocup.png'),
          ('Рюкзак', 'Стильный рюкзак', 500, 5, 'assets/shop/backpack.png'),
          ('Powerbank', 'Фирменный powerbank', 600, 5, 'assets/shop/powerbank.png'),
          ('Беспроводная колонка', 'Портативная колонка', 800, 3, 'assets/shop/speaker.png'),
          ('Худи', 'Фирменное худи', 1000, 2, 'assets/shop/hoodie.png')
      ''');
    }
    // todo раскомментить делиты, если поменялись вопросы
    // await connection.execute('DELETE FROM education_answers WHERE item_id IN (SELECT id FROM education_items);');
    // await connection.execute('DELETE FROM education_items');
    // Проверяем и добавляем образовательные элементы
    final educationItems = await connection.query(
        'SELECT 1 FROM education_items LIMIT 1');
    if (educationItems.isEmpty) {
      await connection.query('''
      INSERT INTO education_items (title, short_description, full_description, correct_category, points) VALUES
        ('NEOCHARITY', 'Обучение детей Scratch и Python', 'Образовательный проект "NEOCHARITY". Программа обучения включает такие направления, как программирование с помощью языков Scratch и Python, создание web-сайтов, графический дизайн.', 'children', 2),
        ('Созвездие 24', 'Встреча с талантливыми детьми', 'Мероприятие "Созвездие 24". Встреча с талантливыми детьми из лагеря «Созвездие», на которой были подняты темы о мире фронтенд-разработки, а также проведена игра, посвященная Искусственному Интеллекту.', 'children', 2),
        ('Разработка 3D-игр', 'Курс по созданию трёхмерных игр', 'Курс по созданию трёхмерных игр с использованием популярных движков и языков программирования.', 'children', 2),
        ('Компьютерная графика', 'Изучение компьютерной графики', 'Направление в онлайн-школе по изучению компьютерной графики с помощью специализированного ПО.', 'children', 2),
        ('Разработка Android-приложений', 'Создание мобильных приложений', 'Курс по созданию мобильных приложений для Android на Java/Kotlin с использованием Android Studio.', 'children', 2),
        ('Neoskills lab', 'Переквалификация ИТ-специалистов', 'Проект по переквалификации ИТ-специалистов, желающих развиваться в новых для себя сферах.', 'adults', 2),
        ('Java - разработка', 'Курс по Java и Spring Framework', 'Курс, включающий в себя основы языка, Spring Framework, работу с БД, тестирование, микросервисы, Docker и Camunda BPM.', 'adults', 2),
        ('Мастеркласс "Мозг vs Генеративный ИИ"', 'Доклад о мышлении и ИИ', 'Доклад об отличиях процесса мышления человека и вычислительных подходов генеративных моделей.', 'adults', 2),
        ('Frontend - разработка', 'Курс по веб-разработке', 'Курс про HTML/CSS, JavaScript/TypeScript, React, архитектуру, стилизацию, безопасность и основы бэкенда.', 'adults', 2),
        ('Мастеркласс "Создание геймифицированного квеста"', 'Доклад об игровых анимациях', 'Доклад об интеграции анимаций в игровой процесс, методах создания интерактивных элементов.', 'adults', 2)
      ''');
    }
  }

  Future<void> initializeTimeMachineQuestions() async {
    final connection = await getConnection();
    try {
      // Сначала удаляем ответы пользователей, связанные с вопросами
      await connection.execute('DELETE FROM user_answers');
      // Удаляем существующие вопросы (опционально)
      await connection.execute('DELETE FROM time_machine_questions');

      // Вопросы для "Рождение кода" (2005-2016)
      await _addQuestionsForEraIfNotExist(connection, 'Рождение кода', [
        {
          'question': 'В каком году был основан Neoflex?',
          'correct': '2005',
          'options': ['2005', '2004', '2006'],
          'points': 3
        },
        {
          'question': 'Какой статус получила компания Neoflex на второй год после основания?',
          'correct': 'IBM Advanced Business Partner',
          'options': ['Microsoft Gold Partner', 'IBM Advanced Business Partner', 'Oracle Platinum Partner'],
          'points': 3
        },
        {
          'question': 'В каком году был открыт филиал в Саратове?',
          'correct': '2011',
          'options': ['2010', '2011', '2012'],
          'points': 3
        },
        {
          'question': 'Neoflex DataGram – уникальный программный акселератор. На каких технологиях он был построен специалистами Neoflex?',
          'correct': 'Big Data',
          'options': ['Blockchain', 'Quantum Computing', 'Big Data'],
          'points': 3
        },
        {
          'question': 'С какой организацией был выполнен проект по интеграции ИТ-систем ООО «банк Раунд» для реализации процессов выпуска и обслуживания банковских карт абонентов оператора связи в 2016 году?',
          'correct': 'ПАО «МегаФон»',
          'options': ['ПАО «МТС»', 'ПАО «МегаФон»', 'ПАО «Билайн»'],
          'points': 3
        },
      ]);

      // Вопросы для "Эпоха прорыва" (2017-2019)
      await _addQuestionsForEraIfNotExist(connection, 'Эпоха прорыва', [
        {
          'question': 'Сколько заказчиков работает с компанией Neoflex в период 2017 года?',
          'correct': '80',
          'options': ['80', '50', '120'],
          'points': 3
        },
        {
          'question': 'Что нового предлагает Neoflex в рамках направления UX и дизайна?',
          'correct': 'Проекты полного цикла – от проектирования до внедрения цифровых продуктов.',
          'options': [
            'Только разработку интерфейсов без внедрения.',
            'Проекты полного цикла – от проектирования до внедрения цифровых продуктов.',
            'Обучение сотрудников заказчика основам графического дизайна.'
          ],
          'points': 3
        },
        {
          'question': 'В 2018 году было создано облачное решение, предназначенное для разработки бизнес-приложений на основе микросервисной архитектуры. Какое название оно имело?',
          'correct': 'Neoflex MSA Platform',
          'options': ['Neoflex MicroHub', 'Neoflex MSA Platform', 'Neoflex CloudCore'],
          'points': 3
        },
        {
          'question': 'В каком городе в ЮАР был открыт офис?',
          'correct': 'Йоханнесбург',
          'options': ['Йоханнесбург', 'Кейптаун', 'Дурбан'],
          'points': 3
        },
        {
          'question': 'Как назывался проект для кросс-медиа аналитики?',
          'correct': 'Mediascope',
          'options': ['MediaTrack', 'Mediascope', 'CrossAnalytics'],
          'points': 3
        },
      ]);

      // Вопросы для "Цифровая революция" (2020-2023)
      await _addQuestionsForEraIfNotExist(connection, 'Цифровая революция', [
        {
          'question': 'Для чего предназначено решение Active Archive от Neoflex?',
          'correct': 'Для хранения и быстрого доступа к архивным данным с автоматизацией отчетности для госорганов',
          'options': [
            'Для хранения и быстрого доступа к архивным данным с автоматизацией отчетности для госорганов',
            'Для создания новых социальных сетей на основе Big Data',
            'Для разработки игровых приложений с использованием архивных данных'
          ],
          'points': 3
        },
        {
          'question': 'Какой язык программирования НЕ использовался на тот момент в центре?',
          'correct': 'Dart',
          'options': ['Swift', 'Dart', 'Objective-C'],
          'points': 3
        },
        {
          'question': 'Какая платформа была создана компанией Neoflex для организаций, использующих в своих бизнес-процессах большое количество ML-моделей?',
          'correct': 'MLOps Center',
          'options': ['MLOps Center', 'AI Factory', 'Deep Learning Hub'],
          'points': 3
        },
        {
          'question': 'Какой продукт был выпущен в 2022 году для оценки эффективности и безопасности облачной инфраструктуры?',
          'correct': 'NeoCAT (Cloud Security Platform)',
          'options': ['NeoCloud Inspector', 'CloudGuard Analytics', 'NeoCAT (Cloud Security Platform)'],
          'points': 15
        },
        {
          'question': 'В каких отраслях Neoflex реализовал инновационные проекты в 2023 году?',
          'correct': 'Финансы, ритейл, страхование, промышленность, инвестиции и девелопмент',
          'options': [
            'Только в финансах и страховании',
            'Финансы, ритейл, страхование, промышленность, инвестиции и девелопмент',
            'Исключительно в сфере IT-стартапов'
          ],
          'points': 3
        },
      ]);
    } finally {
      await connection.close();
    }
  }

  Future<void> _addQuestionsForEraIfNotExist(
    PostgreSQLConnection connection,
    String era,
    List<Map<String, dynamic>> questions) async {
    for (final question in questions) {
      // Проверяем, существует ли уже такой вопрос
      final existing = await connection.query(
        'SELECT 1 FROM time_machine_questions WHERE era = @era AND question_text = @question LIMIT 1',
        substitutionValues: {
          'era': era,
          'question': question['question'],
        },
      );

      if (existing.isEmpty) {
        await connection.query(
          '''
        INSERT INTO time_machine_questions 
          (era, question_text, correct_answer, option1, option2, option3, points)
        VALUES 
          (@era, @question, @correct, @option1, @option2, @option3, @points)
        ''',
          substitutionValues: {
            'era': era,
            'question': question['question'],
            'correct': question['correct'],
            'option1': question['options'][0],
            'option2': question['options'][1],
            'option3': question['options'][2],
            'points': question['points'],
          },
        );
      }
    }
  }
}