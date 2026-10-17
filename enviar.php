<?php
// Envia por email las solicitudes del formulario de presupuesto.

$destino = 'contacto@taratransitoscanarias.com';
$remitente = 'contacto@taratransitoscanarias.com';

function responder($ok, $estado)
{
    http_response_code($estado);
    if (strpos($_SERVER['HTTP_ACCEPT'] ?? '', 'application/json') !== false) {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['ok' => $ok]);
    } else {
        header('Content-Type: text/html; charset=utf-8');
        echo $ok
            ? '<p>Solicitud enviada. Te responderemos en breve.</p>'
            : '<p>No se ha podido enviar la solicitud. Escríbenos a contacto@taratransitoscanarias.com o llama al 699 060 401.</p>';
        echo '<p><a href="/">Volver a la web</a></p>';
    }
    exit;
}

function campo($nombre)
{
    return trim(str_replace(["\r", "\n"], ' ', (string) ($_POST[$nombre] ?? '')));
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(false, 405);
}

// Campo trampa invisible: si llega relleno, lo ha enviado un robot.
if (campo('web') !== '') {
    responder(true, 200);
}

$nombre = campo('nombre');
$telefono = campo('telefono');
$email = campo('email');
$servicio = campo('servicio');
$mensaje = trim((string) ($_POST['mensaje'] ?? ''));

if ($nombre === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || empty($_POST['privacidad']) || strlen($mensaje) > 5000) {
    responder(false, 422);
}

$asunto = '=?UTF-8?B?' . base64_encode('Solicitud de presupuesto: ' . $servicio) . '?=';
$cuerpo = "Nueva solicitud desde la web\n\n"
    . "Nombre: $nombre\n"
    . "Teléfono: $telefono\n"
    . "Email: $email\n"
    . "Servicio: $servicio\n\n"
    . "Mensaje:\n$mensaje\n";
$cabeceras = implode("\r\n", [
    'From: Web Tara Transitos <' . $remitente . '>',
    'Reply-To: ' . $email,
    'MIME-Version: 1.0',
    'Content-Type: text/plain; charset=UTF-8',
    'Content-Transfer-Encoding: 8bit',
]);

$enviado = mail($destino, $asunto, $cuerpo, $cabeceras);
responder($enviado, $enviado ? 200 : 500);
