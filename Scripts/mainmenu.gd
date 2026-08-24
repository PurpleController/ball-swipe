extends Control

@export var text: Array[String]

@onready var admob: Admob = $Admob as Admob
@onready var settings_menu: Panel = $Settings

func _ready() -> void:
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		admob.initialize()
	settings_menu.visible = false
	$Control/text.text = text.pick_random()
	$ScoreLabel.text = "High Score: " + str(HighScore.high_score)

func _on_admob_initialization_completed(status_data: InitializationStatus) -> void:
	for __network_tag in status_data.get_network_tags():
		var __adapter_status: AdapterStatus = status_data.get_adapter_status(__network_tag)
		print(
			(
				"Network '%s' (%s) status: %s [Latency: %d, Description: %s]"
				% [
					__network_tag,
					__adapter_status.get_adapter_class(),
					__adapter_status.get_initialization_state(),
					__adapter_status.get_latency(),
					__adapter_status.get_description(),
				]
			),
		)
	_process_consent_status(admob.get_consent_status())

func _process_consent_status(a_consent_status: UserConsent) -> void:
	match a_consent_status.status:
		UserConsent.Status.UNKNOWN:
			print("consent status is unknown")
			admob.update_consent_info()
		UserConsent.Status.NOT_REQUIRED:
			print("consent is not required")
			_load_ads()
		UserConsent.Status.REQUIRED:
			print("consent is required")
			admob.load_consent_form()
		UserConsent.Status.OBTAINED:
			print("consent has been obtained")
			(
				admob
				. set_mediation_privacy_settings(
					(
						NetworkPrivacySettings
						. new()
						. set_has_gdpr_consent(true)
						. set_is_age_restricted_user(false)
						. set_has_ccpa_sale_consent(true)
					),
				)
			)
			_load_ads()

func _on_update_consent_info_button_pressed() -> void:
	admob.update_consent_info()

func _on_admob_consent_form_loaded() -> void:
	print("consent form has been loaded")
	admob.show_consent_form()


func _on_admob_consent_form_failed_to_load(a_error_data: FormError) -> void:
	print("consent form failed to load %s" % a_error_data.get_message())


func _on_admob_consent_form_dismissed(a_error_data: FormError) -> void:
	print("consent form has been dismissed %s" % a_error_data.get_message())
	_process_consent_status(admob.get_consent_status())

func _on_admob_consent_info_updated() -> void:
	print("consent info updated")
	_process_consent_status(admob.get_consent_status())


func _on_admob_consent_info_update_failed(a_error_data: FormError) -> void:
	print("consent info failed to update: %s" % a_error_data.get_message())

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")


func _on_settings_pressed() -> void:
	settings_menu.visible = true


func _on_back_pressed() -> void:
	settings_menu.visible = false

func _load_ads() -> void:
	pass
