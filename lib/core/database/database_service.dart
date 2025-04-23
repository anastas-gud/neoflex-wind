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
  })  : _host = host ?? '192.168.56.1',
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
    await connection.open();
    return connection;
  }

  Future<void> initDatabase() async {
    final connection = await getConnection();
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
      });

      await _seedInitialData(connection);
    } finally {
      await connection.close();
    }
  }

  Future<void> _seedInitialData(PostgreSQLConnection connection) async {
    // Проверяем и добавляем достижения
    final achievements = await connection.query('SELECT 1 FROM achievements LIMIT 1');
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
    final shopItems = await connection.query('SELECT 1 FROM shop_items LIMIT 1');
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

    // Проверяем и добавляем образовательные элементы
    final educationItems = await connection.query('SELECT 1 FROM education_items LIMIT 1');
    if (educationItems.isEmpty) {
      await connection.query('''
        INSERT INTO education_items (title, short_description, full_description, correct_category, points) VALUES
          ('NEOCHARITY', 'Обучение детей Scratch и Python', 'Образовательный проект "NEOCHARITY". Программа обучения включает такие направления, как программирование с помощью языков Scratch и Python, создание web-сайтов, графический дизайн.', 'children', 10),
          ('Созвездие 24', 'Встреча с талантливыми детьми', 'Мероприятие "Созвездие 24". Встреча с талантливыми детьми из лагеря «Созвездие», на которой были подняты темы о мире фронтенд-разработки, а также проведена игра, посвященная Искусственному Интеллекту.', 'children', 10),
          ('Разработка 3D-игр', 'Курс по созданию трёхмерных игр', 'Курс по созданию трёхмерных игр с использованием популярных движков и языков программирования.', 'children', 10),
          ('Neoskills lab', 'Переквалификация ИТ-специалистов', 'Проект по переквалификации ИТ-специалистов, желающих развиваться в новых для себя сферах.', 'adults', 10),
          ('Java - разработка', 'Курс по Java и Spring Framework', 'Курс, включающий в себя основы языка, Spring Framework, работу с БД, тестирование, микросервисы, Docker и Camunda BPM.', 'adults', 10)
      ''');
    }
  }
}