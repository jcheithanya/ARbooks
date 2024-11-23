// Need external things
import javax.crypto.spec.SecretKeySpec;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.Cipher

////////////////////////////////////////////////////////////////////////////////////////
// LETS GO
class Crypter {

    // Key must be exactly 16 bytes
    def expandKey (def secret) {
 
        for (def i=0; i<4; i++) {
    
            secret += secret        
        }
        
        return secret.substring(0, 16)
    }

    // do the magic
    def encrypt (def plainText, def secret) {
    
        secret = expandKey(secret)
        def cipher = Cipher.getInstance("AES/CBC/PKCS5Padding", "SunJCE")
        SecretKeySpec key = new SecretKeySpec(secret.getBytes("UTF-8"), "AES")
        cipher.init(Cipher.ENCRYPT_MODE, key, new IvParameterSpec(secret.getBytes("UTF-8")))
    
        return cipher.doFinal(plainText.getBytes("UTF-8")).encodeBase64().toString()   
    }
    
    // undo the magic
    def decrypt (def cypherText, def secret) {
    
        byte[] decodedBytes = cypherText.decodeBase64()

        secret = expandKey(secret)
        def cipher = Cipher.getInstance("AES/CBC/PKCS5Padding", "SunJCE")
        SecretKeySpec key = new SecretKeySpec(secret.getBytes("UTF-8"), "AES")
        cipher.init(Cipher.DECRYPT_MODE, key, new IvParameterSpec(secret.getBytes("UTF-8")))

        return new String(cipher.doFinal(decodedBytes), "UTF-8")
    }
}

///////////////////////////////////////////////////////////////////////////////////////
// TEST IT
def c = new Crypter()

def plainBond = execution.getVariable('aesPassword')
def secret = execution.getVariable('aeskey')

def encryptedBond = c.encrypt(plainBond, secret)
println encryptedBond + "\n"

//def decryptedBond = c.decrypt(encryptedBond, secret)
//println encryptedBond + "\n"

execution.setVariable('encryptedtext', encryptedBond)
