package game;

import game.AudioPlayer.MyAudioPlayer;
import game.ui.dialogue.DialogueBoxManager;
import game.TurnSlave.TakeAttackResult;

class Sign extends NPC {
	@:export public var sign_text: String;

	var dialogue_box_manager: DialogueBoxManager;

	public function setup_sign(dialogue_box_manager: DialogueBoxManager) {
		this.dialogue_box_manager = dialogue_box_manager;
		offset_y = 0.0;
	}

	public override function take_attack(attacker: TurnSlave, skill_id: Int): TakeAttackResult {
		dialogue_box_manager.add_text(sign_text);
		MyAudioPlayer.read_sign.play();
		return Interaction;
	}
}
