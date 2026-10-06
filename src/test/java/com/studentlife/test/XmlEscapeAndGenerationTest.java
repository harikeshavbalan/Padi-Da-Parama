package com.studentlife.test;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class XmlEscapeAndGenerationTest {

    @Test
    @DisplayName("XML special characters &, <, >, \", ' are escaped correctly")
    public void testXmlEscape() {
        String raw = "Algorithms & Data Structures <Advanced> '2026' \"Final\"";
        String escaped = escapeXml(raw);

        assertEquals("Algorithms &amp; Data Structures &lt;Advanced&gt; &apos;2026&apos; &quot;Final&quot;", escaped);
    }

    private String escapeXml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&apos;");
    }
}
