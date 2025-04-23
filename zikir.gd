extends Node2D

var Zikir = 0
var titreme = load("res://icon/Titreme.png")
var titrememe = load("res://icon/Titrememe.png")
var gunes = load("res://icon/sun.png")
var ay = load("res://icon/moon.png")
var titresme = true
var Hedefler = []

func _ready() -> void:
	print($Control/ColorRect.color.r)
	Yukleme()
	Titresme_tus_kontrol()
	Tema_tus_kontrol()
	$Control/ZikirSayi.text = "%d" % Zikir

func Kayıt():
	var veri = {
		"zikir": int(Zikir),
		"tema": bool($"Control/Karanlık".visible),
		"renk": {
			"R": int($Control/ColorRect.color.r),
			"G": int($Control/ColorRect.color.g),
			"B": int($Control/ColorRect.color.b),
			"A": int($Control/ColorRect.color.a),},
		"titresme" : bool(titresme),
	}

	var json_string = JSON.stringify(veri)

	var dosya = FileAccess.open("user://zikir.json", FileAccess.WRITE)
	dosya.store_string(json_string)
	dosya.close()
	print("Sahne kaydedildi.")

func Yukleme():
	if not FileAccess.file_exists("user://zikir.json"):
		print("Kayıt dosyası yok.")
		return

	var dosya = FileAccess.open("user://zikir.json", FileAccess.READ)
	var veri = JSON.parse_string(dosya.get_as_text())
	dosya.close()

	if typeof(veri) == TYPE_DICTIONARY:
		Zikir = int(veri["zikir"])
		$"Control/Karanlık".visible = bool(veri["tema"])
		var r = veri["renk"]
		$Control/ColorRect.color = Color(r["R"],r["G"],r["B"],r["A"])
		titresme = bool(veri["titresme"])
		print("Sahne yüklendi.")

func _process(delta: float) -> void:
	pass

func _on_zikir_pressed() -> void:
	Zikir += 1
	$Control/ZikirSayi.text = "%d" % Zikir
	Kayıt()

func _on_sifirla_pressed() -> void:
	$AcceptDialog.visible = !$AcceptDialog.visible

func _on_hedef_ayar_pressed() -> void:
	if $Control/HedefArka.get_size() == Vector2(11,1280):
		$AnimationPlayer.play("AyarlarAcilma")
	else :
		$AnimationPlayer.play("AyarlarAcilma",-1,-1.0,true)

func _on_accept_dialog_confirmed() -> void:
	Zikir = 0
	$Control/ZikirSayi.text = "%d" % Zikir
	Kayıt()

func _on_geri_pressed() -> void:
	Kayıt()
	$AnimationPlayer.play("Geri")

func _on_renk_toggled(toggled_on: bool) -> void:
	if toggled_on == true :
		$AnimationPlayer.play("RenSecim")
	else :
		$AnimationPlayer.play("RenSecim",-1,-1.0,true)

func GeriGitme() -> void:
	get_tree().change_scene_to_file("res://namaz_vakti.tscn")
	
func _on_renk_secim_color_changed(color: Color) -> void:
	$Control/ColorRect.color = color
	Kayıt()

func _on_titresim_pressed() -> void:

	if $HedefMenu/titresim.icon == titrememe :
		$HedefMenu/titresim.icon = titreme
		titresme = true
	else :
		$HedefMenu/titresim.icon = titrememe
		titresme = false
	Kayıt()

func _on_tema_pressed() -> void:

	if $HedefMenu/Tema.icon == ay :
		$HedefMenu/Tema.icon = gunes
		$"Control/Karanlık".visible = true
	else :
		$HedefMenu/Tema.icon = ay 
		$"Control/Karanlık".visible = false
	Kayıt()

func Tema_tus_kontrol() -> void :
	if $"Control/Karanlık".visible == true:
		$HedefMenu/Tema.icon = gunes
	else:
		$HedefMenu/Tema.icon = ay

func Titresme_tus_kontrol() -> void:
	if titresme == true:
		$HedefMenu/titresim.icon = titreme
	else:
		$HedefMenu/titresim.icon = titrememe


func _on_ekle_pressed() -> void:
	var bayrak = false
	var Liste = []
	var kelime = ""
	var kelimesayi = 0
	var GirilenYazi = $HedefMenu/GirilenYazi.text
	for i in GirilenYazi :
		kelimesayi += 1
		bayrak = false
		if i == "," and bayrak == false :
			Liste.append(kelime)
			bayrak = true
			kelime = ""
		elif kelimesayi == GirilenYazi.length() :
			Liste.append(int(kelime+GirilenYazi[-1]))
			Hedefler.append(Liste)
			kelime = ""
			$HedefMenu/GirilenYazi.text = ""
		if bayrak == false :
			kelime += i

func _on_cıkar_pressed() -> void:
	pass # Replace with function body.
