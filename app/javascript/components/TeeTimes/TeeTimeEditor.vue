<template>
  <vue-modal name="tee-time-editor" height="auto" width="85%" :scrollable="false" @before-open="beforeOpen" @before-close="beforeClose" :clickToClose="true">
    <div class="edit-tee-times">
      <div class="edit-tee-times-header">
        <div class="row">
          <div class="col-md-8">
            <h2>Add Players</h2>
          </div>
        </div>
      </div>
      <div class="edit-tee-times-content">
          <div class="row no-gutters">
              <div class="col-md-4">
                <div class="edit-tee-times-left-content mCustomScrollbar" data-mcs-theme="dark">
                  <div class="edit-tee-times-left-content-style">
                    <draggable v-model="teeGroupData.nonRegisteredPlayers" group="players" :move="attemptDrop">
                      <div class="media tee-time-widget" v-for="player in teeGroupData.nonRegisteredPlayers" v-bind:key="player.id">
                        <img :src=player.imageUrl>
                        <div class="media-body">
                          <h2>{{ player.name }}</h2>
                        </div>
                      </div>
                    </draggable>
                  </div>
                </div>
              </div>
              <div class="col-md-8">
                <nav id="autoScroll" class="navbar hidden">
                  <ul class="nav nav-pills">
                    <li class="nav-item">
                      <a class="nav-link" id="listScrollLink" href="#"></a>
                    </li>
                  </ul>
                </nav>
                <div class="edit-tee-times-right-content mCustomScrollbar" data-spy="scroll" data-target="#autoScroll" data-offset="50" data-mcs-theme="dark" id="sortable-groups">
                  <div class="addTeeTimeGreyBtn mt-2" v-on:click="addTournamentGroupAtPosition(0)">
                    <p>Add Previous Tee Time</p>
                  </div>
                  <div v-for="(tournamentGroup, groupIndex) in teeGroupData.tournamentGroups" v-bind:key="tournamentGroup.id" :id=tournamentGroup.id>
                    <div class="heading-style tee-time-popup">
                      <h2 class="text-uppercase">
                        <div class='input-group date editTeeTimeText' >
                          <date-picker class="form-control editTeeTimeInput noBorder" v-model="tournamentGroup.teeTime"></date-picker>
                        </div>
                      </h2>
                      <span class="input-group-addon">
                        <i class="fas fa-pencil-alt editTeeTimeIcon" id="a"></i>
                      </span>
                      <i class="fas fa-trash" v-on:click="deleteTournamentGroup(tournamentGroup)"></i>
                    </div>

                    <draggable v-model="tournamentGroup.players" group="players" class="row drag-player-row" @change="dropInGroup(groupIndex, $event)">
                      <template v-for="player in tournamentGroup.players">
                        <div class="col-md-6 tee-time-widget" v-bind:key="player.id">
                          <div class="media">
                            <img :src=player.imageUrl>
                            <div class="media-body">
                              <h2>{{ player.name }}</h2>
                            </div>
                          </div>
                        </div>
                      </template>

                      <div class="drag-player-box" v-for="n in remainingSlotsForGroup(tournamentGroup)" :id="groupIndex + '-' + n" v-bind:key="groupIndex + '-' + n">
                        <div class="drag-player" :id=n>
                          <p>Drag Player Here</p>
                        </div>
                      </div>
                    </draggable>

                    <div class="addTeeTimeGreyBtn" v-on:click="addTournamentGroupAtPosition(groupIndex + 1)">
                      <p>Add Next Tee Time</p>
                    </div>
                  </div>
                </div>
              </div>
          </div>
      </div> 
    </div> 
  </vue-modal>
</template>

<script>
import draggable from 'vuedraggable';
import datePicker from 'vue-bootstrap-datetimepicker';

import TournamentGroupAPI from '../../api/TournamentGroupAPI';

export default {
  components: {
    draggable,
    datePicker,
  },
  data() {
    return {
      csrfToken: document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      teeGroupData: {
        nonRegisteredPlayers: [],
        tournamentGroups: [],
      },
    };
  },
  methods: {
    beforeOpen(event) {
      this.teeGroupData = event.params.teeGroupData;
    },
    beforeClose(event) {
      window.location.reload();
    },
    remainingSlotsForGroup(tournamentGroup) {
      const remainingSlots = tournamentGroup.maxNumberOfPlayers - tournamentGroup.players.length;
      return remainingSlots >= 0 ? remainingSlots : 0;
    },
    attemptDrop(event) {
      // Can I hide the div for the related empty box? Or use a z-index background?
      return true;
    },
    addTournamentGroupAtPosition(position) {
      const payload = {
        leagueId: this.teeGroupData.leagueId,
        tournamentId: this.teeGroupData.tournamentId,
        tournamentDayId: this.teeGroupData.tournamentDayId,
        position,
      };

      TournamentGroupAPI.createTournamentGroup(this.csrfToken, payload)
        .then((response) => {
          console.log(response);

          this.teeGroupData = response.data;
        });
    },
    deleteTournamentGroup(group) {
      const payload = {
        leagueId: this.teeGroupData.leagueId,
        tournamentId: this.teeGroupData.tournamentId,
        tournamentDayId: this.teeGroupData.tournamentDayId,
        group,
      };

      TournamentGroupAPI.destroyTournamentGroup(this.csrfToken, payload)
        .then((response) => {
          console.log(response);

          this.teeGroupData = response.data;
        });
    },
    dropInGroup(groupId) {
      const group = this.teeGroupData.tournamentGroups[groupId];
      const remainingSlots = group.maxNumberOfPlayers - group.players.length;

      if (remainingSlots < 0) {
        const playerToRemove = group.players.pop();

        this.teeGroupData.nonRegisteredPlayers.push(playerToRemove);
      }

      this.saveGroup(group);
    },
    saveGroup(group) {
      const payload = {
        leagueId: this.teeGroupData.leagueId,
        tournamentId: this.teeGroupData.tournamentId,
        tournamentDayId: this.teeGroupData.tournamentDayId,
        group,
      };

      TournamentGroupAPI.patchTournamentGroup(this.csrfToken, payload);
    },
  },
};
</script>

<style scoped>
.sortable-ghost {
  opacity: .5;
}
</style>
