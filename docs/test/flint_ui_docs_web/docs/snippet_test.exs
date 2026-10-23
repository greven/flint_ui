defmodule FlintUIDocsWeb.Docs.SnippetTest do
  use ExUnit.Case, async: true

  alias FlintUIDocsWeb.Docs.Snippet

  describe "tag/3" do
    test "keeps a short single-line body inline" do
      assert Snippet.tag(".button", [], "Button") == "<.button>Button</.button>"
    end

    test "keeps short attributes inline" do
      assert Snippet.tag(".button", [Snippet.attr("variant", "solid")], "Button") ==
               ~s(<.button variant="solid">Button</.button>)
    end

    test "breaks a tag out when it would not fit on one line" do
      long_class = String.duplicate("a", 80)

      assert Snippet.tag(".button", [Snippet.attr("class", long_class)], "Button") ==
               String.trim("""
               <.button
                 class="#{long_class}"
               >
                 Button
               </.button>
               """)
    end

    test "indents a multi-line body" do
      assert Snippet.tag(".group", [], """
             <.button>Copy</.button>
             <.button>Paste</.button>
             """) ==
               String.trim("""
               <.group>
                 <.button>Copy</.button>
                 <.button>Paste</.button>
               </.group>
               """)
    end
  end

  describe "component/2" do
    test "keeps a short tag inline" do
      assert Snippet.component(".icon", [Snippet.attr("name", "lucide-bolt")]) ==
               ~s(<.icon name="lucide-bolt" />)
    end

    test "breaks a tag out when it would not fit on one line" do
      long_class = String.duplicate("a", 80)

      assert Snippet.component(".icon", [Snippet.attr("class", long_class)]) ==
               String.trim("""
               <.icon
                 class="#{long_class}"
               />
               """)
    end
  end
end
