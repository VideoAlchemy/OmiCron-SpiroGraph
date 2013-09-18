/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  TouchOsc controller for JugglingMolecules sketch
////////////////////////////////////////////////////////////

class MolecularController extends TouchOscController {

	boolean saveLock = false;

	public MolecularController() {
		super();
	}

	// Special stuff to update the config w/weird controls, etc.
	void updateConfig(String fieldName, OscMessage message) {
		// Handle "Load" and "Save" messages
		if (fieldName.startsWith("Load/") || fieldName.startsWith("PS")) {
			String fileName = fieldName.replace("Load/", "");
			gConfig.load(fileName);
			return;
		} else if (fieldName.startsWith("Save/")) {
			String fileName = fieldName.replace("Save/", "");
			if (this.saveLock) gConfig.save(fileName);
			return;
		}

		float value = message.get(0).floatValue();

		// If they're pressing the "Savelock" button, toggle the `saveLock` state.
		// We'll only save if `saveLock` is true.
		if (fieldName.equals("Savelock")) {
			this.saveLock = (value == 1);
println("---- saveLock:	"+this.saveLock);
			return;
		}



		// "particleGenerate" x/y pad
		if (fieldName.equals("particleGenerate")) {
			float otherValue = message.get(1).floatValue();
			gConfig.setFromController("particleGenerateRate", value, this.minValue, this.maxValue);
			gConfig.setFromController("particleGenerateSpread", otherValue, this.minValue, this.maxValue);
			return;
		}

		// "noise" x/y pad
		else if (fieldName.equals("noise")) {
			// x-y pad which returns 2 values
			float otherValue = message.get(1).floatValue();
			gConfig.setFromController("noiseStrength", value, this.minValue, this.maxValue);
			gConfig.setFromController("noiseScale", otherValue, this.minValue, this.maxValue);
			return;
		}

		// "particleColorScheme-0", "particleColorScheme-1", etc
		else if (fieldName.startsWith("particleColorScheme-")) {
			int mode = int(fieldName.replace("particleColorScheme-", ""));
			fieldName = "particleColorScheme";
			value = (float) mode;
		}

		// "depthImageBlendMode-0", "depthImageBlendMode-1", etc
		else if (fieldName.startsWith("depthImageBlendMode-")) {
			int mode = int(fieldName.replace("depthImageBlendMode-", ""));
			fieldName = "depthImageBlendMode";
			value = (float) mode;
		}

		// hue controls.  Note that the config currently expects "Color" to be setting hue value.
		else if (fieldName.contains("Hue")) {
			fieldName = fieldName.replace("Hue", "") + "Color";
		}

		gConfig.setFromController(fieldName, value, this.minValue, this.maxValue);
	}


	// Special case for fields with special needs.
	void onFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {
		this.sendLabel(fieldName, valueLabel);

		// map "Color" to "Hue"
		if (fieldName.endsWith("Color")) fieldName = fieldName.replace("Color", "Hue");

		// always send the raw value
		this.sendFloat(fieldName, controllerValue);

		// do "specials"

		// "particleGenerate" x/y pad
		if (fieldName.equals("particleGenerateRate") || fieldName.equals("particleGenerateSpread")) {
			this.sendXY("particleGenerate", "particleGenerateRate", "particleGenerateSpread");
		}

		// "noise" x/y pad
		else if (fieldName.equals("noiseStrength") || fieldName.equals("noiseScale")) {
			this.sendXY("noise", "noiseStrength", "noiseScale");
		}

		// particleColorScheme toggles
		else if (fieldName.equals("particleColorScheme"))	{
			this.sendChoice("particleColorScheme", controllerValue, 3);
		}

		// depthImageBlendMode toggles
		else if (fieldName.equals("depthImageBlendMode")) {
			int[] choices = {0,1,2,4,8,16,32,64,128,256};
			this.sendChoice("depthImageBlendMode", controllerValue, choices);
		}

	}

}