<?php
	$host = 'postgres';
	$user = 'postgres';
	$pass = 'tsi23lesboss';
	$db = 'postgres';

	$errors = [];
	try {
		$conn = @new PDO("pgsql:host=$host;dbname=$db", $user, $pass);
	} catch (Exception $err) {
		$conn = null;
	}

	$str_id_gite = $_GET["id"];
	$id_gite = intval($str_id_gite);

	$sql =  "SELECT annee, commentaire, loyer_moyen FROM vue_gite_commentaire WHERE id_gite = $id_gite";
	$commentaires = [];

	if (!$conn) {
		$errors[] = "Fail to connect database";
	} else {
		try {
			$result = $conn -> query($sql);
		} catch (Exception $err) {
			$result = [];
			$errors[] = $err -> getMessage();
		}

		foreach  ($result as [
			"annee" => $annee,
			"commentaire" => $commentaire,
			"loyer_moyen" => $loyer_moyen
		]) {
			$commentaires[$annee] = [
				"commentaire" => $commentaire,
				"loyer_moyen" => $loyer_moyen
			];
		}
	}

	$lenght = count($commentaires);

	if ($lenght == 0) {
		$errors[] = "Unfound gite id $id_gite";
	}

	header('Content-Type: application/json; charset=utf-8');
	echo json_encode([
		"length" => $lenght,
		"errors" => $errors,
		"data" => $commentaires,
	]);
?>
