package guestbook.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import guestbook.GuestBookEntry;

import java.net.URL;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Map;

public class EntryResponseModel {
    private final GuestBookEntry entry;

    public EntryResponseModel(GuestBookEntry entry) {
        this.entry = entry;
    }

    public String getId() {
        return entry.getEntryId();
    }

    public String getName() {
        return entry.getAuthor();
    }

    public String getMessage() {
        return entry.getMessage();
    }

    public Map<String, URL> getImages() {
        return entry.getResizedPictures();
    }

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss Z", timezone = "UTC")
    public ZonedDateTime getDatetime() {
        return entry.getCreatedAt().atZoneSameInstant(ZoneId.of("UTC"));
    }
}
