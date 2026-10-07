// =====================================================
// FUEL STATION MANAGEMENT SYSTEM - JAVASCRIPT
// =====================================================


// -----------------------------------------------------
// DELETE CONFIRMATION
// -----------------------------------------------------

function confirmDelete() {

    return confirm(
        "Are you sure you want to delete this record?"
    );

}


// -----------------------------------------------------
// LIVE CLOCK
// -----------------------------------------------------

function updateClock() {

    const clock = document.getElementById("clock");

    if (clock) {

        const now = new Date();

        clock.textContent = now.toLocaleTimeString(
            "en-IN",
            {
                hour: "2-digit",
                minute: "2-digit",
                second: "2-digit"
            }
        );

    }

}


// Update clock every second

setInterval(
    updateClock,
    1000
);


// Run immediately

updateClock();