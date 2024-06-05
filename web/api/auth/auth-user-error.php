<?php

function getAuthErrorMessage($errorCode, $language = "en")
{
    $errorMessages = array(
        1 => array(
            'en' => 'Invalid email format.',
            'es' => 'Formato de correo electrónico no válido.',
            'it' => 'Formato email non valido.',
            'fr' => 'Format d\'email invalide.',
            'de' => 'Ungültiges E-Mail-Format.',
            'ru' => 'Неверный формат электронной почты.',
            'pt' => 'Formato de e-mail inválido.',
        ),
        2 => array(
            'en' => 'Password must be at least 8 characters.',
            'es' => 'La contraseña debe tener al menos 8 caracteres.',
            'it' => 'La password deve contenere almeno 8 caratteri.',
            'fr' => 'Le mot de passe doit comporter au moins 8 caractères.',
            'de' => 'Das Passwort muss mindestens 8 Zeichen enthalten.',
            'ru' => 'Пароль должен быть не менее 8 символов.',
            'pt' => 'A senha deve ter pelo menos 8 caracteres.',
        ),
        3 => array(
            'en' => 'Password must contain at least one letter.',
            'es' => 'La contraseña debe contener al menos una letra.',
            'it' => 'La password deve contenere almeno una lettera.',
            'fr' => 'Le mot de passe doit contenir au moins une lettre.',
            'de' => 'Das Passwort muss mindestens einen Buchstaben enthalten.',
            'ru' => 'Пароль должен содержать как минимум одну букву.',
            'pt' => 'A senha deve conter pelo menos uma letra.',
        ),
        4 => array(
            'en' => 'Password must contain at least one number.',
            'es' => 'La contraseña debe contener al menos un número.',
            'it' => 'La password deve contenere almeno un numero.',
            'fr' => 'Le mot de passe doit contenir au moins un chiffre.',
            'de' => 'Das Passwort muss mindestens eine Nummer enthalten.',
            'ru' => 'Пароль должен содержать хотя бы одну цифру.',
            'pt' => 'A senha deve conter pelo menos um número.',
        ),
        5 => array(
            'en' => 'User not found.',
            'es' => 'Usuario no encontrado.',
            'it' => 'Utente non trovato.',
            'fr' => 'Utilisateur non trouvé.',
            'de' => 'Benutzer nicht gefunden.',
            'ru' => 'Пользователь не найден.',
            'pt' => 'Usuário não encontrado.',
        ),
        6 => array(
            'en' => 'User already exists.',
            'es' => 'El usuario ya existe.',
            'it' => 'L\'utente esiste già.',
            'fr' => 'L\'utilisateur existe déjà.',
            'de' => 'Benutzer existiert bereits.',
            'ru' => 'Пользователь уже существует.',
            'pt' => 'Usuário já existe.',
        ),
        7 => array(
            'en' => 'Wrong password.',
            'es' => 'Contraseña incorrecta.',
            'it' => 'Password errata.',
            'fr' => 'Mot de passe incorrect.',
            'de' => 'Falsches Passwort.',
            'ru' => 'Неверный пароль.',
            'pt' => 'Senha incorreta.',
        ),
    );

    return isset($errorMessages[$errorCode][$language]) ? $errorMessages[$errorCode][$language] : $errorMessages[$errorCode]["en"];
}
