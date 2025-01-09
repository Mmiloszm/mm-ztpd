package lucene;

import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import java.io.IOException;
import java.nio.file.Paths;

public class Index {
    private static final String INDEX_DIRECTORY = "lucene_index";

    public static void main(String[] args) throws IOException {
        Directory directory = FSDirectory.open(Paths.get(INDEX_DIRECTORY));
        PolishAnalyzer analyzer = new PolishAnalyzer();
        IndexWriterConfig config = new IndexWriterConfig(analyzer);

        try (IndexWriter writer = new IndexWriter(directory, config)) {
            writer.addDocument(buildDoc("Lucyna w akcji", "9780062316097"));
            writer.addDocument(buildDoc("Akcje rosną i spadają", "9780385545955"));
            writer.addDocument(buildDoc("Bo ponieważ", "9781501168007"));
            writer.addDocument(buildDoc("Naturalnie urodzeni mordercy", "9780316485616"));
            writer.addDocument(buildDoc("Druhna rodzi", "9780593301760"));
            writer.addDocument(buildDoc("Urodzić się na nowo", "9780679777489"));
            System.out.println("Indeks został utworzony.");
        }
    }

    private static Document buildDoc(String title, String isbn) {
        Document doc = new Document();
        doc.add(new TextField("title", title, Field.Store.YES));
        doc.add(new StringField("isbn", isbn, Field.Store.YES));
        return doc;
    }
}
