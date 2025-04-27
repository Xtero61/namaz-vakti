extends Node2D

var Zikir = 0
var titreme = load("res://icon/Titreme.png")
var titrememe = load("res://icon/Titrememe.png")
var gunes = load("res://icon/sun.png")
var ay = load("res://icon/moon.png")
var titresme = true
var CekilenHedefler = []
var CekilenHedefSayi = []
var hedefler = false
var cekilenHedef = 0

func _ready() -> void:
	Yukleme()
	Titresme_tus_kontrol()
	Tema_tus_kontrol()
	if hedefler == false :
		Hedef_yazma()
		$HedefMenu/Label/CheckButton.button_pressed = true
		$HedefMenu/GirilenYazi.editable = true
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
		"CekilenHedefler" : Array(CekilenHedefler),
		"CekilenHedefSayi": Array(CekilenHedefSayi),
		"hedefler": bool(hedefler),
		"cekilenHedef": int(cekilenHedef),
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
		CekilenHedefler = Array(veri["CekilenHedefler"])
		CekilenHedefSayi = Array(veri["CekilenHedefSayi"])
		hedefler = bool(veri["hedefler"])
		cekilenHedef = int(veri["cekilenHedef"])
		print("Sahne yüklendi.")

func _process(_delta: float) -> void:
	pass

func _on_zikir_pressed() -> void:
	if hedefler == false :
		if CekilenHedefler.size() > 0 :
			if CekilenHedefSayi[cekilenHedef] == Zikir :
				Zikir = 0
				$Control/ZikirSayi.text = "%d" % Zikir
				Secili_hedef_degisme()
				Hedef_yazma()
			else:
				Zikir_artırma_yazma()
		else :
			Zikir_artırma_yazma()
	else :
		Zikir_artırma_yazma()
	if CekilenHedefSayi[cekilenHedef] == Zikir :
		Input.vibrate_handheld(500)
	Kayıt()

func Secili_hedef_degisme() -> void :
	if CekilenHedefler.size() > 1 :
		if cekilenHedef == CekilenHedefler.size()-1 :
			if titresme == true :
				cekilenHedef = 0
		else:
			cekilenHedef += 1

func Zikir_artırma_yazma() -> void :
	Zikir += 1
	$Control/ZikirSayi.text = "%d" % Zikir

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
	if $HedefMenu/titresim.icon == titreme :
		$HedefMenu/titresim.icon = titrememe
		titresme = true
	else :
		$HedefMenu/titresim.icon = titreme
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
		$HedefMenu/titresim.icon = titrememe
	else:
		$HedefMenu/titresim.icon = titreme

func bas_harfler_buyuk_yap(metin: String) -> String:
	var kelimeler = metin.split(" ")
	for i in kelimeler.size():
		var kelime = kelimeler[i]
		if kelime.length() > 0:
			var ilk = kelime.unicode_at(0)
			var ilk_harf = String.chr(ilk).to_upper()
			kelimeler[i] = ilk_harf + kelime.substr(1)
	return " ".join(kelimeler)

func _on_ekle_pressed() -> void:
	var bayrak = false
	var kelime = ""
	var kelimesayi = 0
	var GirilenYazi = $HedefMenu/GirilenYazi.text.to_lower()
	if GirilenYazi.contains(","):
		var parcalar = GirilenYazi.split(",", false)
		if parcalar.size() > 1 and parcalar[1].strip_edges() != "":
			for i in GirilenYazi :
				kelimesayi += 1
				bayrak = false
				if i == "," and bayrak == false :
					CekilenHedefler.append(kelime)
					bayrak = true
					kelime = ""
				elif kelimesayi == GirilenYazi.length() :
					CekilenHedefSayi.append(int(kelime+GirilenYazi[-1]))
					kelime = ""
					$HedefMenu/GirilenYazi.text = ""
					Hata_goster("Kelime Eklendi")
				if bayrak == false :
					kelime += i
		else :
			Hata_goster("Virgülden sonrası boş olamaz")
	else:
		Hata_goster("Anlatılan şekilde yazınız")
	Hedef_yazma()

func _on_cıkar_pressed() -> void:
	var GirilenYazi = $HedefMenu/GirilenYazi.text.to_lower()
	if CekilenHedefler.find(GirilenYazi) > -1 :
		CekilenHedefSayi.remove_at(CekilenHedefler.find(GirilenYazi))
		CekilenHedefler.erase(GirilenYazi)
		Hata_goster("Kelime Silindi")
		$HedefMenu/GirilenYazi.text = ""
	else :
		Hata_goster("Böyle bir kelime bulunmuyor")
	Hedef_yazma()

func Hata_goster(hata : String) -> void:
	$HedefMenu/hata.text = hata
	$"HedefMenu/hata görünme".start()

func _on_ipucu_pressed() -> void:
	pass # Replace with function body.

func _on_hata_görünme_timeout() -> void:
	$HedefMenu/hata.text = ""

func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on == false:
		hedefler = true
		$HedefMenu/GirilenYazi.editable = false
		$Control/CekilenZikir.text = ""
		$Control/CekilenZikirSayi.text = ""
	else :
		hedefler = false
		$HedefMenu/GirilenYazi.editable = true
		Hedef_yazma()
	Kayıt()

func Hedef_yazma() -> void :
	if CekilenHedefler.size() > 0:
		$Control/CekilenZikir.text = "%s" % bas_harfler_buyuk_yap(CekilenHedefler[cekilenHedef])
		$Control/CekilenZikirSayi.text = "%s" % int(CekilenHedefSayi[cekilenHedef])
	else :
		$Control/CekilenZikir.text = "Önce hedef eklemelisin"
